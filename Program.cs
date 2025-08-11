using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Google.Cloud.Storage.V1;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BatchProcessor;

public class Program
{
    public static async Task Main(string[] args)
    {
        var host = Host.CreateDefaultBuilder(args)
            .ConfigureServices((context, services) =>
            {
                services.AddSingleton<StorageClient>(provider => StorageClient.Create());
                services.AddScoped<CsvProcessor>();
                services.AddScoped<BatchService>();
            })
            .Build();

        var logger = host.Services.GetRequiredService<ILogger<Program>>();
        var batchService = host.Services.GetRequiredService<BatchService>();

        try
        {
            logger.LogInformation("Starting CSV Batch Processing Job...");
            await batchService.ProcessCsvFilesAsync();
            logger.LogInformation("CSV Batch Processing Job completed successfully.");
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Batch processing job failed.");
            Environment.Exit(1);
        }
    }
}

public class BatchService
{
    private readonly StorageClient _storageClient;
    private readonly CsvProcessor _csvProcessor;
    private readonly ILogger<BatchService> _logger;
    
    private readonly string _inputBucket = Environment.GetEnvironmentVariable("INPUT_BUCKET") ?? "csv-input-bucket";
    private readonly string _outputBucket = Environment.GetEnvironmentVariable("OUTPUT_BUCKET") ?? "csv-processed-bucket";

    public BatchService(StorageClient storageClient, CsvProcessor csvProcessor, ILogger<BatchService> logger)
    {
        _storageClient = storageClient;
        _csvProcessor = csvProcessor;
        _logger = logger;
    }

    public async Task ProcessCsvFilesAsync()
    {
        _logger.LogInformation("Processing CSV files from bucket: {InputBucket}", _inputBucket);

        try
        {
            // List all CSV files in the input bucket
            var objects = _storageClient.ListObjects(_inputBucket, prefix: "");
            var csvFiles = objects.Where(obj => obj.Name.EndsWith(".csv", StringComparison.OrdinalIgnoreCase));

            foreach (var csvFile in csvFiles)
            {
                try
                {
                    _logger.LogInformation("Processing file: {FileName}", csvFile.Name);
                    
                    // Download CSV file
                    var csvContent = await DownloadFileAsync(_inputBucket, csvFile.Name);
                    
                    // Process CSV content
                    var processedData = await _csvProcessor.ProcessCsvDataAsync(csvContent);
                    
                    // Upload processed data
                    var outputFileName = "processed_" + DateTime.UtcNow.ToString("yyyyMMdd_HHmmss") + "_" + csvFile.Name;
                    await UploadProcessedDataAsync(_outputBucket, outputFileName, processedData);
                    
                    _logger.LogInformation("Successfully processed: {FileName}", csvFile.Name);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to process file: {FileName}", csvFile.Name);
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to list objects in bucket: {InputBucket}", _inputBucket);
            throw;
        }
    }

    private async Task<string> DownloadFileAsync(string bucketName, string fileName)
    {
        using var stream = new MemoryStream();
        await _storageClient.DownloadObjectAsync(bucketName, fileName, stream);
        return Encoding.UTF8.GetString(stream.ToArray());
    }

    private async Task UploadProcessedDataAsync(string bucketName, string fileName, string content)
    {
        var bytes = Encoding.UTF8.GetBytes(content);
        using var stream = new MemoryStream(bytes);
        
        await _storageClient.UploadObjectAsync(bucketName, fileName, "text/csv", stream);
    }
}

public class CsvProcessor
{
    private readonly ILogger<CsvProcessor> _logger;

    public CsvProcessor(ILogger<CsvProcessor> logger)
    {
        _logger = logger;
    }

    public async Task<string> ProcessCsvDataAsync(string csvContent)
    {
        _logger.LogInformation("Processing CSV data...");

        var lines = csvContent.Split('\n', StringSplitOptions.RemoveEmptyEntries);
        var processedLines = new List<string>();

        // Add processing timestamp header
        if (lines.Length > 0)
        {
            var headers = lines[0];
            processedLines.Add(headers + ",ProcessedTimestamp,Status");
        }

        // Process each data row
        for (int i = 1; i < lines.Length; i++)
        {
            var line = lines[i].Trim();
            if (!string.IsNullOrEmpty(line))
            {
                // Add processing metadata
                var processedLine = line + "," + DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss") + ",Processed";
                processedLines.Add(processedLine);
            }
        }

        _logger.LogInformation("Processed {RowCount} rows", processedLines.Count - 1);
        return string.Join('\n', processedLines);
    }
}
