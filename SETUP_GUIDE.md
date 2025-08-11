# 🚀 Batch-Processor Independent Test Setup

**Goal**: Simple, focused test of JFrog connectivity and Docker build/push

## 📋 **Setup Steps**

### **Step 1: Create GitHub Repository**
1. Go to: https://github.com/new
2. Repository name: `batch-processor`
3. Owner: `shirish36`
4. Set as: Public
5. Click: "Create repository"

### **Step 2: Add GitHub Secrets**
1. Go to: https://github.com/shirish36/batch-processor/settings/secrets/actions
2. Add these secrets:

| Secret Name | Value |
|-------------|-------|
| `JFROG_REGISTRY_URL` | `trial4jlj6w.jfrog.io` |
| `JFROG_USERNAME` | `[your-jfrog-username]` |
| `JFROG_PASSWORD` | `[your-jfrog-password]` |

### **Step 3: Push Code**
```bash
# In the batch-processor directory (where you are now)
git remote add origin https://github.com/shirish36/batch-processor.git
git branch -M main
git push -u origin main
```

### **Step 4: Test Workflow**
1. Go to: https://github.com/shirish36/batch-processor/actions
2. Find: "Test Build and Push to JFrog"
3. Click: "Run workflow" (manual trigger)
4. Watch: The build and push process

## 🎯 **What This Will Test**

✅ **JFrog Authentication**: Verify credentials work  
✅ **Docker Build**: Build .NET 8.0 batch processor  
✅ **Container Test**: Ensure image runs correctly  
✅ **JFrog Push**: Upload to trial4jlj6w.jfrog.io  
✅ **End-to-End**: Complete workflow success  

## 📦 **Expected Output**

**Images in JFrog Artifactory:**
```
trial4jlj6w.jfrog.io/shirish-docker/batch-processor:test-[timestamp]
trial4jlj6w.jfrog.io/shirish-docker/batch-processor:latest
```

## 🔧 **Workflow Features**

- **Simple and focused**: Only tests what you need
- **Clear logging**: Shows each step clearly
- **Error handling**: Reports issues clearly
- **Cleanup**: Removes local images after push
- **Manual trigger**: Can run on-demand

---

**Ready to create the GitHub repository and test!**

**Current location**: `D:\Mission 2025\DevOps\sample-applications\batch-processor`  
**Git status**: Repository initialized and committed  
**Next**: Create GitHub repo and push code
