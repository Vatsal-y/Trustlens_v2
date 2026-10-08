# ⚠️ Git Clone Error (Exit Code 128) - Troubleshooting Guide

## Error Message
```
❌ Git command error: Cmd('git') failed due to: exit code(128)
  cmdline: git clone -v --branch=main --progress -- https://github.com/kavyacp123/trend-pulse-spark.git /tmp/repo-trend-pulse-spark
```

---

## 🎯 Root Cause

**Exit code 128** means **Git command execution failed**. This typically indicates:

1. **Git is NOT installed** ⚠️ (Most Common)
2. Git is not in system PATH
3. Network connectivity issue
4. Permission denied on temp directory
5. Authentication failure (for private repos)

---

## ✅ Solution 1: Install Git (Most Likely Fix)

### On Linux/Ubuntu/Debian
```bash
# Update package list
sudo apt-get update

# Install Git
sudo apt-get install -y git

# Verify installation
git --version
```

### On CentOS/RHEL/Fedora
```bash
sudo yum install -y git

# Verify
git --version
```

### On Alpine Linux
```bash
apk add git

# Verify
git --version
```

### On Windows (WSL/Docker Windows)
Inside WSL terminal:
```bash
sudo apt-get update
sudo apt-get install -y git
git --version
```

### On Docker
Add to your Dockerfile:
```dockerfile
# Install Git
RUN apt-get update && apt-get install -y git

# Verify
RUN git --version
```

---

## ✅ Solution 2: Run Diagnostic Tool

The system now includes an improved diagnostic tool:

```bash
cd backend
python diagnose_git_issue.py
```

This will:
- ✅ Check if Git is installed
- ✅ Verify Git configuration
- ✅ Test network connectivity
- ✅ Check temp directory permissions
- ✅ Test SSH setup (optional)
- ✅ Attempt a test clone
- ✅ Check GitPython installation

---

## ✅ Solution 3: Check Your Environment

### Is Git in PATH?
```bash
which git       # Linux/Mac
where git       # Windows CMD
Get-Command git # Windows PowerShell
```

**Expected output:** Path to git executable like `/usr/bin/git`

### If not in PATH:
- Reinstall Git and ensure PATH option is selected
- Or manually add Git to PATH environment variable

---

## ✅ Solution 4: Verify GitPython Package

```bash
# Check if GitPython is installed
pip list | grep GitPython

# If not found, install it:
pip install GitPython
```

---

## 🔍 Detailed Error Diagnosis

### Error Code 128 Meanings:
| Scenario | Fix |
|----------|-----|
| `git: not found` | Install Git |
| `command not found: git` | Add Git to PATH |
| `fatal: could not resolve host` | Check internet connection |
| `fatal: Authentication failed` | Check credentials/SSH key |
| `fatal: repository not found` | Verify repo URL exists |
| `permission denied` | Check folder permissions |

---

## 🧪 Manual Test Clone

Test Git clone manually to isolate the issue:

```bash
# Create test directory
mkdir -p /tmp/test-git

# Change to test directory
cd /tmp/test-git

# Try cloning a small repo
git clone --depth 1 https://github.com/torvalds/linux.git test-repo

# If successful, cleanup:
rm -rf test-repo
```

If this works, the issue is in TrustLens configuration.

---

## 📋 Pre-Check Checklist

Before trying again, verify:

- [ ] Git is installed: `git --version` returns a version
- [ ] Git is in PATH: `which git` returns a path
- [ ] Internet is working: `ping github.com` succeeds
- [ ] Temp directory is writable: `touch /tmp/test.txt` works
- [ ] GitPython is installed: `pip list | grep GitPython`
- [ ] Repository URL is correct: URL format is valid
- [ ] No firewall blocking: Check your firewall/proxy settings

---

## 🚀 After Fixing Git

Once Git is installed, the system will:

1. **Auto-detect** Git installation on startup
2. **Log** Git version on initialization
3. **Provide better error messages** if issues occur
4. **Retry clone** with improved diagnostics

### Log Output to Expect:
```
[GitHandler] ✅ Git is installed: git version 2.34.1
[GitHandler] 🔄 Starting clone: https://github.com/...
[GitHandler] ✅ Successfully cloned: trend-pulse-spark
```

---

## 🆘 Still Having Issues?

### Check Log Messages
Look for these improved error messages in your logs:

```
💡 DIAGNOSIS: Git is not installed or not in PATH
FIX: apt-get install -y git (Linux) or install Git (Windows)
```

```
💡 DIAGNOSIS: Network connectivity issue
FIX: Check internet connection
```

```
💡 DIAGNOSIS: Authentication failed
FIX: Check credentials or SSH key setup
```

### Try Using HTTPS Instead of SSH
- If using SSH URLs: switch to HTTPS
- GitHub: Use `https://github.com/user/repo.git` format

### Check Docker/Container Environment
If running in Docker:
1. Verify Git is installed in the image
2. Check Dockerfile includes `RUN apt-get install -y git`
3. Rebuild image: `docker build --no-cache .`

---

## 📚 Additional Resources

- **Git Installation Guide:** https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
- **GitHub SSH Setup:** https://docs.github.com/en/authentication/connecting-to-github-with-ssh
- **Docker Git Installation:** https://docs.docker.com/engine/reference/builder/#run
- **GitPython Documentation:** https://gitpython.readthedocs.io/

---

## 🎯 Quick Reference Commands

```bash
# Install Git (Ubuntu/Debian)
sudo apt-get update && sudo apt-get install -y git

# Verify Git installation
git --version

# Check GitPython
pip install GitPython

# Run TrustLens diagnostic
python backend/diagnose_git_issue.py

# Test clone manually
git clone --depth 1 https://github.com/torvalds/linux.git /tmp/test-repo
```

---

## ✨ What Changed in the Code

The `git_handler.py` has been improved with:

1. **Automatic Git detection** on initialization
2. **Detailed error diagnosis** in exception handlers
3. **Helpful error messages** with specific fixes
4. **Exit code detection** (128 = Git not installed)

The system will now tell you exactly what's wrong and how to fix it!

---

## 📞 Support

If issues persist after installing Git:

1. ✅ Run `python diagnose_git_issue.py`
2. 📋 Check the detailed output
3. 🔧 Follow the suggested solutions
4. 🧪 Test manually: `git clone https://github.com/...`
5. 🚀 Retry through TrustLens API

---

**Status:** Ready to use once Git is installed! 🚀
