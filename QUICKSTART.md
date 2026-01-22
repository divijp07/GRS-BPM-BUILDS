# Quick Start Guide - Testing the GitHub Actions Workflow

## Prerequisites
1. GitHub repository with this workflow file
2. Git installed locally
3. Access to the repositories listed in `SonarGitFiles/*.txt`

## Step 1: Push to GitHub

```powershell
# Navigate to your repository
cd "c:\Users\patediv\Downloads\GRS-grs-bpm-builds_bpm-dev\GRS-grs-bpm-builds_bpm-dev"

# Initialize git if not already done
git init

# Add files
git add .github/workflows/bpm-build.yml
git add .github/workflows/README.md
git commit -m "Add GitHub Actions workflow for BPM builds"

# Add remote (replace with your GitHub repo URL)
git remote add origin https://github.com/YOUR_ORG/YOUR_REPO.git

# Push to GitHub
git push -u origin main
```

## Step 2: Run the Workflow Manually

1. Go to your GitHub repository
2. Click on **Actions** tab
3. Click on **BPM Build Pipeline** in the left sidebar
4. Click **Run workflow** button (top right)
5. Fill in the parameters:
   - **Application(s) to build**: Start with a single app like `agreement`
   - **Release version**: `grs`
   - **Branch type**: `develop`
6. Click **Run workflow**

## Step 3: Monitor the Build

- Click on the running workflow to see live logs
- Each step will show its progress
- Download artifacts when complete

---

## Testing Locally with `act`

You can test GitHub Actions locally using the `act` tool:

### Install act
```powershell
# Using winget
winget install nektos.act

# Or using Chocolatey
choco install act-cli
```

### Run the workflow locally
```powershell
# Test with default inputs
act workflow_dispatch

# Test with specific inputs
act workflow_dispatch --input app_to_build=agreement --input release=grs --input branch_type=develop

# Dry run to see what would execute
act workflow_dispatch --dry-run
```

**Note**: Local testing has limitations:
- May not have access to secrets
- Repository cloning might fail without proper credentials
- Some GitHub-specific features won't work

---

## Quick Test Strategy

### Test 1: Single Application (Fastest)
```
app_to_build: agreement
release: grs
branch_type: develop
```
This will build just one application to verify the workflow works.

### Test 2: Multiple Applications
```
app_to_build: agreement,authorization,findcustomer
release: grs
branch_type: develop
```
Test with a few applications to verify the loop works.

### Test 3: Full Build (Slowest)
```
app_to_build: ALL
release: grs
branch_type: develop
```
Build everything - may take 60-120 minutes.

---

## Troubleshooting Common Issues

### Issue: Repository clone fails
**Cause**: Git URLs in `SonarGitFiles/*.txt` may not be accessible

**Fix**: 
1. Check if URLs are correct
2. Ensure you have access to those repositories
3. Configure SSH keys or tokens as GitHub secrets
4. Use the SSH workflow version if needed

### Issue: Ant build fails
**Cause**: Missing dependencies or incorrect paths

**Fix**:
1. Check that `build-single.xml` exists
2. Verify `Properties/build_*.properties` files exist
3. Review build logs for specific errors

### Issue: No artifacts uploaded
**Cause**: Build didn't create EAR/JAR files

**Fix**:
1. Check build logs for errors
2. Verify the build completed successfully
3. Check if `target/ear/` directory was created

---

## Next Steps After Successful Test

1. ✅ Review downloaded artifacts
2. ✅ Compare with Jenkins build outputs
3. ✅ Set up automatic triggers (push/PR)
4. ✅ Add deployment steps
5. ✅ Configure notifications
