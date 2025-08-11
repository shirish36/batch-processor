#!/bin/bash

# 🚀 Manual Setup Script for Cloud Run Job Infrastructure
# Run this script to set up the Cloud Run Job manually

set -e

# Configuration
PROJECT_ID="gifted-palace-468618-q5"
REGION="us-central1"
SERVICE_ACCOUNT="github-actions@gifted-palace-468618-q5.iam.gserviceaccount.com"

echo "🏗️ Setting up Cloud Run Job Infrastructure"
echo "📍 Project: $PROJECT_ID"
echo "📍 Region: $REGION"
echo "🔐 Service Account: $SERVICE_ACCOUNT"
echo ""

# Check if gcloud is installed and authenticated
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI is not installed. Please install it first."
    exit 1
fi

if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ Not authenticated to gcloud. Please run: gcloud auth login"
    exit 1
fi

# Set the project
echo "🔧 Setting up gcloud configuration..."
gcloud config set project $PROJECT_ID
gcloud config set run/region $REGION

echo "✅ Project and region configured"

# Enable required APIs
echo ""
echo "🔧 Enabling required APIs..."
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com  
gcloud services enable containerregistry.googleapis.com

echo "✅ APIs enabled successfully"

# Configure Docker for GCR
echo ""
echo "🐳 Configuring Docker for Google Container Registry..."
gcloud auth configure-docker --quiet

echo "✅ Docker configured for GCR"

# Create placeholder image
echo ""
echo "📦 Creating placeholder image in GCR..."

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

# Create simple Dockerfile
cat << 'EOF' > Dockerfile
FROM gcr.io/google-appengine/debian11
RUN echo "Placeholder for batch-processor - will be replaced by deployment workflow" > /placeholder.txt
CMD ["cat", "/placeholder.txt"]
EOF

# Build and push placeholder
PLACEHOLDER_IMAGE="gcr.io/$PROJECT_ID/batch-processor:placeholder"
docker build -t "$PLACEHOLDER_IMAGE" .
docker push "$PLACEHOLDER_IMAGE"

echo "✅ Placeholder image created: $PLACEHOLDER_IMAGE"

# Clean up temp directory
cd - > /dev/null
rm -rf $TEMP_DIR

# Create Cloud Run Jobs for each environment
echo ""
echo "🚀 Creating Cloud Run Jobs..."

for ENV in dev staging prod; do
    JOB_NAME="batch-processor-$ENV"
    
    echo "  📝 Creating job: $JOB_NAME"
    
    if gcloud run jobs describe "$JOB_NAME" --region="$REGION" >/dev/null 2>&1; then
        echo "  ℹ️ Job $JOB_NAME already exists, updating..."
        gcloud run jobs replace --quiet << EOF
apiVersion: run.googleapis.com/v1
kind: Job
metadata:
  name: $JOB_NAME
spec:
  template:
    spec:
      template:
        spec:
          serviceAccountName: $SERVICE_ACCOUNT
          containers:
          - image: $PLACEHOLDER_IMAGE
            env:
            - name: ENVIRONMENT
              value: $ENV
            - name: GCP_PROJECT_ID
              value: $PROJECT_ID
            resources:
              limits:
                cpu: 1000m
                memory: 2Gi
          restartPolicy: Never
          timeoutSeconds: 3600
      backoffLimit: 3
      parallelism: 1
EOF
    else
        gcloud run jobs create "$JOB_NAME" \
            --image="$PLACEHOLDER_IMAGE" \
            --region="$REGION" \
            --max-retries=3 \
            --parallelism=1 \
            --cpu=1 \
            --memory=2Gi \
            --task-timeout=3600 \
            --service-account="$SERVICE_ACCOUNT" \
            --set-env-vars="ENVIRONMENT=$ENV,GCP_PROJECT_ID=$PROJECT_ID" \
            --quiet
    fi
    
    echo "  ✅ Job $JOB_NAME ready"
done

echo ""
echo "🎉 Infrastructure Setup Complete!"
echo "=================================="
echo "✅ APIs enabled"
echo "✅ Docker configured for GCR"
echo "✅ Placeholder image: $PLACEHOLDER_IMAGE"
echo "✅ Cloud Run Jobs created:"
echo "  - batch-processor-dev"
echo "  - batch-processor-staging" 
echo "  - batch-processor-prod"
echo ""
echo "🔗 Next Steps:"
echo "1. Add GitHub secrets to your repository"
echo "2. Use 'Deploy to GCP Cloud Run Job' workflow"
echo "3. Your JFrog images will replace the placeholder"
echo ""
echo "🌐 GCP Console:"
echo "  https://console.cloud.google.com/run/jobs?project=$PROJECT_ID"
echo ""
echo "🎯 Ready for deployment!"
