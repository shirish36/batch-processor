# 🚀 JFrog to Cloud Run Job - Deployment Options

You have **3 different ways** to deploy your Docker image from JFrog Artifactory to Cloud Run Job:

## 📋 **Comparison of Deployment Methods**

| Method | Pros | Cons | Use Case |
|--------|------|------|----------|
| **Direct Deploy** | ✅ Fastest<br>✅ No intermediate steps<br>✅ Saves GCR storage costs | ❌ Requires JFrog credentials in Cloud Run<br>❌ Slower cold starts | Quick testing, development |
| **Copy to GCR** | ✅ Better security<br>✅ Faster cold starts<br>✅ No JFrog access needed at runtime | ❌ Extra step<br>❌ Uses GCR storage | Production deployments |
| **Update Terraform** | ✅ Infrastructure as Code<br>✅ Version controlled<br>✅ Consistent with existing setup | ❌ Requires Terraform apply<br>❌ More complex | Production, infrastructure changes |

## 🎯 **Option 1: Direct Deploy (Simplest)**

**What it does:**
- Cloud Run Job pulls directly from JFrog during deployment
- No intermediate copy to Google Container Registry
- Fastest deployment

**Workflow file:** `.github/workflows/direct-deploy-jfrog.yml`

**How to use:**
1. Add your existing JFrog + GCP secrets
2. Run workflow manually
3. Choose image tag and environment

**Command equivalent:**
```bash
gcloud run jobs replace my-job \
  --image="trial4jlj6w.jfrog.io/shirish-docker-docker-local/batch-processor:latest" \
  --region=us-central1
```

## 🔄 **Option 2: Copy to GCR (Recommended for Production)**

**What it does:**
- Pulls image from JFrog Artifactory
- Tags and pushes to Google Container Registry
- Deploys to Cloud Run Job from GCR

**Workflow file:** `.github/workflows/deploy-to-gcp.yml` (already created)

**Benefits:**
- Better security (no JFrog credentials needed at runtime)
- Faster cold starts (GCR is closer to Cloud Run)
- Standard GCP practice

## 🏗️ **Option 3: Update Terraform (Infrastructure as Code)**

**What it does:**
- Updates Terraform variable with new image tag
- Runs `terraform apply` to update infrastructure
- Maintains infrastructure state

**Steps:**
1. Update `terraform.tfvars` with new image:
   ```hcl
   batch_image = "trial4jlj6w.jfrog.io/shirish-docker-docker-local/batch-processor:latest"
   ```
2. Run terraform apply:
   ```bash
   terraform apply
   ```

## 🎪 **Quick Start - Direct Deploy**

Since you asked about using the image directly, here's the quickest way:

### **1. Use the Direct Deploy Workflow**
I created `.github/workflows/direct-deploy-jfrog.yml` for you.

### **2. Add Required Secrets**
You already have most of them:
- ✅ `JFROG_REGISTRY_URL`
- ✅ `JFROG_USERNAME` 
- ✅ `JFROG_PASSWORD`
- ✅ `GCP_PROJECT_ID`
- ✅ `GCP_REGION`
- ✅ `GCP_WORKLOAD_IDENTITY_PROVIDER`
- ✅ `GCP_SERVICE_ACCOUNT`

### **3. Run the Workflow**
1. Go to Actions tab
2. Select "Direct Deploy JFrog to Cloud Run Job"
3. Click "Run workflow"
4. Choose:
   - **Image tag:** `latest` or `test-20250811-033649`
   - **Environment:** `dev`

## ⚡ **Fastest Method - Manual gcloud Command**

If you want to deploy **right now** without any workflow:

```bash
# Set your variables
export PROJECT_ID="gifted-palace-468618-q5"
export REGION="us-central1"
export IMAGE="trial4jlj6w.jfrog.io/shirish-docker-docker-local/batch-processor:latest"

# Deploy directly
gcloud run jobs replace batch-processor-dev \
  --image="$IMAGE" \
  --region="$REGION" \
  --max-retries=3 \
  --parallelism=1 \
  --task-count=1 \
  --cpu=1 \
  --memory=2Gi \
  --task-timeout=3600

# Execute the job
gcloud run jobs execute batch-processor-dev --region="$REGION"
```

## 🎯 **My Recommendation**

**For immediate testing:** Use **Direct Deploy** workflow or manual gcloud command
**For production:** Use **Copy to GCR** workflow (already created)

## 🔧 **Authentication Considerations**

### **Direct Deploy:**
- Cloud Run needs JFrog credentials at runtime
- Slightly slower cold starts (pulls from external registry)

### **Copy to GCR:**
- No runtime credentials needed
- Faster cold starts
- Better security isolation

---

**🚀 Ready to deploy!** Choose the method that fits your needs. All three workflows are ready to use!
