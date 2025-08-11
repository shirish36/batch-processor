# 🧪 Batch Processor - JFrog Test

**Purpose**: Simple test to verify JFrog Artifactory connectivity and Docker build/push

## 🎯 **What This Tests**

1. **🔐 JFrog Authentication** - Verify credentials work
2. **🐳 Docker Build** - Build the .NET 8.0 batch processor image  
3. **🧪 Container Test** - Ensure the built image runs correctly
4. **📦 JFrog Push** - Push image to trial4jlj6w.jfrog.io
5. **✅ End-to-End Verification** - Complete workflow success

## 🔑 **Required Secrets**

Add these to the **batch-processor repository** secrets:

| Secret Name | Value |
|-------------|-------|
| `JFROG_REGISTRY_URL` | `trial4jlj6w.jfrog.io` |
| `JFROG_USERNAME` | `[your-jfrog-username]` |
| `JFROG_PASSWORD` | `[your-jfrog-password]` |

## 🚀 **How to Run**

### **Option 1: Automatic Trigger**
```bash
# Make any change to this repository
echo "Test $(date)" >> README.md
git add .
git commit -m "Test JFrog workflow"
git push origin main
```

### **Option 2: Manual Trigger**
1. Go to Actions tab in this repository
2. Select "Test Build and Push to JFrog"
3. Click "Run workflow"

## 📦 **Expected Output**

### **JFrog Artifactory Images:**
```
trial4jlj6w.jfrog.io/shirish-docker-docker-local/batch-processor:test-20250810-220000
trial4jlj6w.jfrog.io/shirish-docker-docker-local/batch-processor:latest
```

### **Workflow Steps:**
```
✅ Checkout code
✅ Display repository info
✅ Set up Docker Buildx
✅ Generate image tag
✅ Test JFrog Authentication
✅ Build Docker image
✅ Test Docker image
✅ Push to JFrog Artifactory
✅ Verify JFrog push
✅ Clean up
```

## 🎯 **Success Criteria**

- [x] JFrog authentication works
- [x] Docker image builds without errors
- [x] Container starts and runs .NET 8.0
- [x] Images push successfully to JFrog
- [x] Images are visible in JFrog Artifactory

---

**Simple, focused test for batch-processor JFrog integration!**
