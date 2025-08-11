# 🔍 How to Find Your GCP_WORKLOAD_IDENTITY_PROVIDER

The `GCP_WORKLOAD_IDENTITY_PROVIDER` is the resource name of your Workload Identity Federation provider. Here's how to find it:

## 🔧 **Method 1: Using gcloud CLI**

### **1. List Workload Identity Pools**
```bash
gcloud iam workload-identity-pools list --location=global
```

### **2. List Providers in the Pool**
```bash
# Replace 'github-pool' with your actual pool name if different
gcloud iam workload-identity-pools providers list \
  --location=global \
  --workload-identity-pool=github-pool
```

### **3. Get Full Provider Resource Name**
```bash
# This will show the full resource name you need
gcloud iam workload-identity-pools providers describe github-provider \
  --location=global \
  --workload-identity-pool=github-pool \
  --format="value(name)"
```

**Expected output format:**
```
projects/123456789/locations/global/workloadIdentityPools/github-pool/providers/github-provider
```

## 🌐 **Method 2: Using GCP Console**

1. Go to [IAM & Admin > Workload Identity Federation](https://console.cloud.google.com/iam-admin/workload-identity-pools)
2. Click on your pool (likely named `github-pool`)
3. Click on your provider (likely named `github-provider`)
4. Copy the **Resource name** from the details page

## 🎯 **Quick Commands to Get All Values**

Run these commands to get all the secrets you need:

### **Get Project Info**
```bash
# Get project ID
export PROJECT_ID=$(gcloud config get-value project)
echo "GCP_PROJECT_ID: $PROJECT_ID"

# Get project number (needed for WIF)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
echo "Project Number: $PROJECT_NUMBER"
```

### **Get Region**
```bash
# List available regions
gcloud compute regions list --filter="name~us|name~europe" --limit=10

# Common choices: us-central1, us-east1, europe-west1
echo "GCP_REGION: us-central1"  # Choose your preferred region
```

### **Get Workload Identity Provider**
```bash
# Get the full provider resource name
gcloud iam workload-identity-pools providers list \
  --location=global \
  --workload-identity-pool=github-pool \
  --format="value(name)"
```

### **Get Service Account**
```bash
# List service accounts
gcloud iam service-accounts list --filter="displayName~GitHub"

# Or get the one from your Terraform
gcloud iam service-accounts list --filter="email~github-actions"
```

## 🔄 **If Workload Identity Federation Doesn't Exist**

If the commands above return empty results, you need to create WIF first:

### **1. Create Workload Identity Pool**
```bash
gcloud iam workload-identity-pools create github-pool \
  --location=global \
  --display-name="GitHub Actions Pool"
```

### **2. Create GitHub Provider**
```bash
gcloud iam workload-identity-pools providers create-oidc github-provider \
  --location=global \
  --workload-identity-pool=github-pool \
  --display-name="GitHub Actions Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.actor=assertion.actor" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

### **3. Create Service Account for GitHub Actions**
```bash
gcloud iam service-accounts create github-actions-sa \
  --display-name="GitHub Actions Service Account"
```

### **4. Bind Service Account to GitHub Repository**
```bash
export REPO="shirish36/batch-processor"  # Your repository
export SA_EMAIL="github-actions-sa@$PROJECT_ID.iam.gserviceaccount.com"

gcloud iam service-accounts add-iam-policy-binding $SA_EMAIL \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/$REPO"
```

### **5. Grant Required Permissions**
```bash
# Grant permissions needed for Cloud Run and Container Registry
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/iam.serviceAccountUser"
```

## 📋 **Final Secret Values**

After running the commands above, you'll have:

```bash
# These are your GitHub secrets:
echo "GCP_PROJECT_ID: $PROJECT_ID"
echo "GCP_REGION: us-central1"  # Or your chosen region
echo "GCP_WORKLOAD_IDENTITY_PROVIDER: projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
echo "GCP_SERVICE_ACCOUNT: github-actions-sa@$PROJECT_ID.iam.gserviceaccount.com"
```

## 🔍 **Verify Setup**

Test your WIF configuration:
```bash
# This should return your service account details
gcloud iam workload-identity-pools providers describe github-provider \
  --location=global \
  --workload-identity-pool=github-pool
```

---

**📌 Pro Tip:** Save the output of these commands - you'll need these exact values for your GitHub repository secrets!
