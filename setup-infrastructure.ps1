# 🚀 PowerShell Setup Script for Cloud Run Job Infrastructure
# Run this script to set up the Cloud Run Job on Windows

# Configuration
$PROJECT_ID = "gifted-palace-468618-q5"
$REGION = "us-central1"  
$SERVICE_ACCOUNT = "github-actions@gifted-palace-468618-q5.iam.gserviceaccount.com"

Write-Host "🏗️ Setting up Cloud Run Job Infrastructure" -ForegroundColor Green
Write-Host "📍 Project: $PROJECT_ID" -ForegroundColor Cyan
Write-Host "📍 Region: $REGION" -ForegroundColor Cyan
Write-Host "🔐 Service Account: $SERVICE_ACCOUNT" -ForegroundColor Cyan
Write-Host ""

# Check if gcloud is available
try {
    $null = gcloud --version
    Write-Host "✅ gcloud CLI found" -ForegroundColor Green
} catch {
    Write-Host "❌ gcloud CLI not found. Please install Google Cloud SDK first." -ForegroundColor Red
    exit 1
}

# Check authentication
$activeAccount = gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>$null
if (-not $activeAccount) {
    Write-Host "❌ Not authenticated to gcloud. Please run: gcloud auth login" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Authenticated as: $activeAccount" -ForegroundColor Green

# Set project and region
Write-Host ""
Write-Host "🔧 Setting up gcloud configuration..." -ForegroundColor Yellow
gcloud config set project $PROJECT_ID
gcloud config set run/region $REGION

Write-Host "✅ Project and region configured" -ForegroundColor Green

# Enable APIs
Write-Host ""
Write-Host "🔧 Enabling required APIs..." -ForegroundColor Yellow
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable containerregistry.googleapis.com

Write-Host "✅ APIs enabled successfully" -ForegroundColor Green

# Configure Docker
Write-Host ""
Write-Host "🐳 Configuring Docker for Google Container Registry..." -ForegroundColor Yellow
gcloud auth configure-docker --quiet

Write-Host "✅ Docker configured for GCR" -ForegroundColor Green

# Create placeholder image
Write-Host ""
Write-Host "📦 Creating placeholder image in GCR..." -ForegroundColor Yellow

# Create temp directory
$tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
Push-Location $tempDir

# Create Dockerfile
@'
FROM gcr.io/google-appengine/debian11
RUN echo "Placeholder for batch-processor - will be replaced by deployment workflow" > /placeholder.txt
CMD ["cat", "/placeholder.txt"]
'@ | Out-File -FilePath "Dockerfile" -Encoding ASCII

# Build and push
$placeholderImage = "gcr.io/$PROJECT_ID/batch-processor:placeholder"
docker build -t $placeholderImage .
docker push $placeholderImage

Write-Host "✅ Placeholder image created: $placeholderImage" -ForegroundColor Green

# Clean up
Pop-Location
Remove-Item $tempDir -Recurse -Force

# Create Cloud Run Jobs
Write-Host ""
Write-Host "🚀 Creating Cloud Run Jobs..." -ForegroundColor Yellow

$environments = @("dev", "staging", "prod")

foreach ($env in $environments) {
    $jobName = "batch-processor-$env"
    Write-Host "  📝 Creating job: $jobName" -ForegroundColor Cyan
    
    # Check if job exists
    $jobExists = $false
    try {
        $null = gcloud run jobs describe $jobName --region=$REGION 2>$null
        $jobExists = $true
        Write-Host "  ℹ️ Job $jobName already exists, updating..." -ForegroundColor Yellow
    }
    catch {
        Write-Host "  📝 Creating new job $jobName..." -ForegroundColor Cyan
    }
    
    if ($jobExists) {
        # Update existing job
        gcloud run jobs update $jobName `
            --image=$placeholderImage `
            --region=$REGION `
            --max-retries=3 `
            --parallelism=1 `
            --cpu=1 `
            --memory=2Gi `
            --task-timeout=3600 `
            --service-account=$SERVICE_ACCOUNT `
            --set-env-vars="ENVIRONMENT=$env,GCP_PROJECT_ID=$PROJECT_ID" `
            --quiet
    } else {
        # Create new job
        gcloud run jobs create $jobName `
            --image=$placeholderImage `
            --region=$REGION `
            --max-retries=3 `
            --parallelism=1 `
            --cpu=1 `
            --memory=2Gi `
            --task-timeout=3600 `
            --service-account=$SERVICE_ACCOUNT `
            --set-env-vars="ENVIRONMENT=$env,GCP_PROJECT_ID=$PROJECT_ID" `
            --quiet
    }
    
    Write-Host "  ✅ Job $jobName ready" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Infrastructure Setup Complete!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host "✅ APIs enabled" -ForegroundColor Green
Write-Host "✅ Docker configured for GCR" -ForegroundColor Green
Write-Host "✅ Placeholder image: $placeholderImage" -ForegroundColor Green
Write-Host "✅ Cloud Run Jobs created:" -ForegroundColor Green
Write-Host "  - batch-processor-dev" -ForegroundColor Cyan
Write-Host "  - batch-processor-staging" -ForegroundColor Cyan
Write-Host "  - batch-processor-prod" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔗 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Add GitHub secrets to your repository" -ForegroundColor White
Write-Host "2. Use 'Deploy to GCP Cloud Run Job' workflow" -ForegroundColor White
Write-Host "3. Your JFrog images will replace the placeholder" -ForegroundColor White
Write-Host ""
Write-Host "🌐 GCP Console:" -ForegroundColor Yellow
Write-Host "  https://console.cloud.google.com/run/jobs?project=$PROJECT_ID" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎯 Ready for deployment!" -ForegroundColor Green
