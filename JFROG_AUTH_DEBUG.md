# 🔍 JFrog Authentication Debug Guide

## 🚨 **Current Issue:**
The JFrog authentication is failing with "Bad Credentials" error.

## 🔧 **Troubleshooting Steps:**

### **Step 1: Verify JFrog Registry URL**
Your registry URL: `trial4jlj6w.jfrog.io`

Test if it's accessible:
```bash
curl -I https://trial4jlj6w.jfrog.io/v2/
```

Expected response: Should return HTTP headers (even if 401/403)

### **Step 2: Check Username Format**
JFrog accepts different username formats:
- **Email**: `shirishrane26@gmail.com` 
- **Username**: `shirish36` (your GitHub username)
- **Full format**: `shirish36@trial4jlj6w`

### **Step 3: Verify Password/Token**
JFrog Cloud uses **API Keys** or **Identity Tokens**, not account passwords.

#### **Get Your API Key:**
1. Login to JFrog: https://trial4jlj6w.jfrog.io
2. Go to **User Profile** → **Generate API Key**
3. Copy the generated API key

#### **Get Identity Token (Alternative):**
1. Go to **User Profile** → **Authentication Settings**
2. Generate **Identity Token**
3. Use this instead of password

### **Step 4: Test Authentication Locally**

```bash
# Test with API Key
echo "YOUR_API_KEY" | docker login trial4jlj6w.jfrog.io --username shirishrane26@gmail.com --password-stdin

# Test with different username format
echo "YOUR_API_KEY" | docker login trial4jlj6w.jfrog.io --username shirish36 --password-stdin

# Test direct pull (to verify repository exists)
docker pull trial4jlj6w.jfrog.io/shirish-docker-docker-local/batch-processor:latest
```

### **Step 5: Common Solutions**

#### **Solution A: Use API Key Instead of Password**
```bash
# Generate API key from JFrog web UI, then:
echo "YOUR_JFROG_API_KEY" | docker login trial4jlj6w.jfrog.io --username shirishrane26@gmail.com --password-stdin
```

#### **Solution B: Try Different Username**
```bash
# Try with GitHub username
echo "YOUR_JFROG_API_KEY" | docker login trial4jlj6w.jfrog.io --username shirish36 --password-stdin
```

#### **Solution C: Use Identity Token**
```bash
# Use identity token instead of API key
echo "YOUR_IDENTITY_TOKEN" | docker login trial4jlj6w.jfrog.io --username shirishrane26@gmail.com --password-stdin
```

## 🔑 **GitHub Secrets Update**

Once you find the working combination, update these GitHub secrets:

| Secret Name | Current Value | Correct Value |
|-------------|---------------|---------------|
| `JFROG_REGISTRY_URL` | `trial4jlj6w.jfrog.io` | ✅ Correct |
| `JFROG_USERNAME` | `?` | `shirishrane26@gmail.com` or `shirish36` |
| `JFROG_PASSWORD` | `?` | **API Key** or **Identity Token** |

## 🧪 **Quick Test Commands**

### **Test 1: Registry Accessibility**
```bash
curl -I https://trial4jlj6w.jfrog.io/v2/
```

### **Test 2: Repository Listing (with auth)**
```bash
curl -u "USERNAME:API_KEY" https://trial4jlj6w.jfrog.io/artifactory/api/repositories
```

### **Test 3: Docker Login**
```bash
echo "API_KEY" | docker login trial4jlj6w.jfrog.io --username USERNAME --password-stdin
```

### **Test 4: List Images in Repository**
```bash
curl -u "USERNAME:API_KEY" "https://trial4jlj6w.jfrog.io/artifactory/api/docker/shirish-docker-docker-local/v2/_catalog"
```

## 🎯 **Most Likely Solution**

The issue is probably that you're using your **account password** instead of an **API Key**.

### **Steps to Fix:**
1. **Login to JFrog**: https://trial4jlj6w.jfrog.io
2. **Go to Profile** → **Generate API Key**
3. **Copy the API Key**
4. **Test locally**:
   ```bash
   echo "YOUR_NEW_API_KEY" | docker login trial4jlj6w.jfrog.io --username shirishrane26@gmail.com --password-stdin
   ```
5. **Update GitHub Secret**: `JFROG_PASSWORD` = Your new API key

## 🚨 **Security Note**
Never use your JFrog account password in scripts. Always use:
- **API Keys** for automation
- **Identity Tokens** for temporary access
- **Access Tokens** for service accounts

---

**🔧 Try the API key solution first - this fixes 90% of JFrog authentication issues!**
