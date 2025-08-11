# JFrog CLI Workflow Setup Guide

## 🚀 New Workflow Created: `build-jfrog-with-cli.yml`

This workflow uses the **JFrog CLI** instead of Docker login, which should resolve the authentication issues we encountered.

## ⚙️ Required GitHub Configuration

### 1. GitHub Variables (Repository Settings → Secrets and variables → Actions → Variables)
```
JF_URL = https://trial4jlj6w.jfrog.io
```

### 2. GitHub Secrets (Repository Settings → Secrets and variables → Actions → Secrets)
```
JF_ACCESS_TOKEN = YOUR_JFROG_REFERENCE_TOKEN_HERE
```
(Use your latest reference token: `cmVm****`)

## 🔧 Setup Steps

### Step 1: Add GitHub Variable
1. Go to your repository: https://github.com/shirish36/devops-infrastructure
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **Variables** tab → **New repository variable**
4. Name: `JF_URL`
5. Value: `https://trial4jlj6w.jfrog.io`
6. Click **Add variable**

### Step 2: Add GitHub Secret
1. Still in the same page, click **Secrets** tab → **New repository secret**
2. Name: `JF_ACCESS_TOKEN`
3. Value: `YOUR_JFROG_REFERENCE_TOKEN` (the one that starts with `cmVm****`)
4. Click **Add secret**

## 🧪 Testing the Workflow

### Option 1: Manual Trigger (Recommended)
1. Go to **Actions** tab in your repository
2. Select **"Build and Deploy to JFrog with CLI"** workflow
3. Click **"Run workflow"**
4. Choose:
   - Environment: `dev`
   - Image tag: `latest`
5. Click **"Run workflow"**

### Option 2: Auto-trigger on Push
The workflow will also run automatically when you push to the `main` branch.

## 🔄 What This Workflow Does

1. **✅ Build**: Uses `jf docker build` to build your .NET application
2. **✅ Push to JFrog**: Uses `jf docker push` to upload to JFrog Artifactory
3. **✅ Build Info**: Collects and publishes build information to JFrog
4. **✅ Pull & Re-tag**: Pulls from JFrog and tags for Google Container Registry
5. **✅ Deploy**: Updates your Cloud Run Job with the new image
6. **✅ Test**: Executes the job and shows logs
7. **✅ Summary**: Provides deployment summary in GitHub Actions

## 🚨 Expected Results

- **JFrog**: Your image will be stored in `trial4jlj6w.jfrog.io/shirish-docker-docker/batch-processor:latest`
- **GCR**: Image will be copied to `gcr.io/mission-2025-devops/batch-processor:latest`
- **Cloud Run**: Job `batch-processor-dev` will be updated and executed
- **Logs**: You'll see the application output in the workflow logs

## 🔍 Troubleshooting

If the workflow fails:
1. Check that both `JF_URL` variable and `JF_ACCESS_TOKEN` secret are set correctly
2. Verify your JFrog token is still valid (check expiration)
3. Ensure your Cloud Run Job infrastructure is still deployed

## ✅ Next Steps

1. Set up the GitHub variable and secret as described above
2. Run the workflow manually to test
3. Check the results in both JFrog and GCP

This approach should completely bypass the Docker login authentication issues we encountered!
