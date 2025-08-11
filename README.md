# Batch Processor Application

This is a batch processing application that processes CSV files from Google Cloud Storage and loads data into Cloud SQL database.

## Features

- CSV file processing from Google Cloud Storage
- Data validation and transformation
- Bulk insert to Cloud SQL database
- Error handling and logging
- Dead letter queue for failed records
- Progress tracking and notifications
- Docker containerization
- Cloud Run Jobs integration

## Technology Stack

- **.NET 8.0** - Runtime and framework
- **Entity Framework Core** - Database ORM
- **CsvHelper** - CSV processing
- **Google Cloud Storage** - File storage
- **Google Cloud SQL** - Database
- **Serilog** - Logging
- **Polly** - Retry policies

## Project Structure

```
batch-processor/
├── Models/
│   ├── CsvRecord.cs
│   ├── ProcessingResult.cs
│   └── AppDbContext.cs
├── Services/
│   ├── ICsvProcessor.cs
│   ├── CsvProcessor.cs
│   ├── IStorageService.cs
│   ├── StorageService.cs
│   ├── IDataService.cs
│   └── DataService.cs
├── Configuration/
│   ├── BatchConfig.cs
│   └── StorageConfig.cs
├── Program.cs
├── Dockerfile
├── appsettings.json
├── BatchProcessor.csproj
└── README.md
```

## CSV Processing Workflow

1. **File Discovery**: Scan Cloud Storage bucket for new CSV files
2. **File Download**: Download CSV file to temporary storage
3. **Data Validation**: Validate CSV structure and data quality
4. **Data Transformation**: Clean and transform data as needed
5. **Batch Processing**: Process records in configurable batch sizes
6. **Database Insert**: Bulk insert valid records to database
7. **Error Handling**: Log and queue failed records for retry
8. **File Cleanup**: Move processed files to archive bucket
9. **Notification**: Send completion notifications

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `ConnectionStrings__DefaultConnection` | Database connection string | `Server=...;Database=...` |
| `STORAGE_BUCKET` | Source bucket for CSV files | `my-project-csv-files` |
| `PROCESSED_BUCKET` | Archive bucket for processed files | `my-project-processed-files` |
| `GOOGLE_CLOUD_PROJECT` | GCP Project ID | `my-project-123` |
| `BATCH_SIZE` | Records per batch | `1000` |
| `MAX_RETRY_ATTEMPTS` | Maximum retry attempts | `3` |

## CSV File Format

Expected CSV format:
```csv
ID,Name,Email,Department,Salary,HireDate
1,John Doe,john.doe@company.com,Engineering,75000,2023-01-15
2,Jane Smith,jane.smith@company.com,Marketing,65000,2023-02-01
```

### Required Columns
- **ID**: Unique identifier (integer)
- **Name**: Employee name (string, max 100 chars)
- **Email**: Email address (valid email format)
- **Department**: Department name (string, max 50 chars)
- **Salary**: Salary amount (decimal)
- **HireDate**: Hire date (yyyy-MM-dd format)

## Local Development

### Prerequisites
- .NET 8.0 SDK
- Docker (for containerization)
- Google Cloud SDK (for local testing)
- SQL Server or Cloud SQL access

### Setup

1. Clone the repository:
```bash
git clone https://github.com/shirish36/batch-processor.git
cd batch-processor
```

2. Install dependencies:
```bash
dotnet restore
```

3. Configure settings in `appsettings.Development.json`

4. Set up Google Cloud credentials:
```bash
gcloud auth application-default login
```

5. Run the application:
```bash
dotnet run
```

## Docker Build

```bash
# Build image
docker build -t batch-processor .

# Run container
docker run \
  -e ConnectionStrings__DefaultConnection="your-connection-string" \
  -e STORAGE_BUCKET="your-bucket" \
  -e GOOGLE_CLOUD_PROJECT="your-project" \
  batch-processor
```

## Cloud Run Jobs

### Deploy to Cloud Run Jobs

```bash
# Build and push to GCR
gcloud builds submit --tag gcr.io/PROJECT_ID/batch-processor

# Deploy to Cloud Run Jobs
gcloud run jobs create batch-processor \
  --image=gcr.io/PROJECT_ID/batch-processor \
  --region=us-central1 \
  --set-env-vars="STORAGE_BUCKET=my-bucket" \
  --set-env-vars="GOOGLE_CLOUD_PROJECT=PROJECT_ID"
```

### Manual Execution

```bash
# Execute job manually
gcloud run jobs execute batch-processor --region=us-central1
```

### Scheduled Execution

Use Cloud Scheduler to run the batch job on a schedule:

```bash
# Create scheduled job (daily at 2 AM)
gcloud scheduler jobs create http batch-processor-schedule \
  --schedule="0 2 * * *" \
  --uri="https://us-central1-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/PROJECT_ID/jobs/batch-processor:run" \
  --http-method=POST \
  --oauth-service-account-email=SERVICE_ACCOUNT_EMAIL
```

## Error Handling

### Data Validation Errors
- Invalid data types
- Missing required fields
- Constraint violations
- Format errors

### Processing Errors
- Database connection issues
- Storage access problems
- Memory limitations
- Timeout errors

### Retry Strategy
- Exponential backoff
- Dead letter queue for persistent failures
- Maximum retry attempts
- Error notifications

## Monitoring and Logging

### Logging Levels
- **Information**: Normal processing events
- **Warning**: Validation failures, retries
- **Error**: Processing failures, exceptions
- **Critical**: System failures, data corruption

### Metrics
- Records processed per minute
- Success/failure rates
- Processing duration
- Memory usage
- Storage I/O metrics

### Alerts
- Job failures
- High error rates
- Long processing times
- Storage quota issues

## Performance Optimization

### Batch Processing
- Configurable batch sizes
- Parallel processing
- Memory-efficient streaming
- Connection pooling

### Database Optimization
- Bulk insert operations
- Transaction batching
- Index optimization
- Connection management

### Storage Optimization
- Streaming downloads
- Compression support
- Parallel file processing
- Cleanup automation

## Testing

```bash
# Unit tests
dotnet test

# Integration tests with test database
dotnet test --filter Category=Integration

# Load testing with sample data
dotnet test --filter Category=Load
```

## Configuration

### appsettings.json
```json
{
  "Batch": {
    "BatchSize": 1000,
    "MaxRetryAttempts": 3,
    "RetryDelaySeconds": 30,
    "ParallelismDegree": 4
  },
  "Storage": {
    "SourceBucket": "csv-files",
    "ProcessedBucket": "processed-files",
    "TempDirectory": "/tmp/batch-processing"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "BatchProcessor": "Debug"
    }
  }
}
```

## Security

- Service account with minimal permissions
- Encrypted data in transit and at rest
- Input validation and sanitization
- Secure credential management
- Network security with VPC

## Troubleshooting

### Common Issues

1. **Permission Errors**
   - Check service account permissions
   - Verify IAM roles for Storage and SQL

2. **Memory Issues**
   - Reduce batch size
   - Increase Cloud Run memory allocation

3. **Timeout Errors**
   - Increase Cloud Run timeout
   - Optimize database queries

4. **File Format Issues**
   - Validate CSV format
   - Check encoding (UTF-8)
   - Verify column headers

##  Docker Build Test

**Build Date**: 2025-08-10 22:08:59  
**Purpose**: Testing JFrog Artifactory integration  
**Workflow**: build-batch-processor.yml  


###  Trigger Test

**Second attempt**: 2025-08-10 22:17:20  
**Reason**: Manual trigger test  

