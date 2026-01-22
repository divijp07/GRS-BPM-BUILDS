# GitHub Actions Migration Guide

## Overview

This GitHub Actions workflow replaces the Jenkins PowerShell build process defined in `jenkins_buildfile.txt`. It provides the same functionality with improved portability and modern CI/CD practices.

## Key Features

### 1. **User Input Support** (replaces Jenkins parameters)
The workflow accepts the same inputs as Jenkins:
- `app_to_build`: Comma-separated list of applications or "ALL"
- `release`: Release version (e.g., "grs")
- `branch_type`: Branch type (e.g., "develop")

### 2. **Automatic Triggers**
- Manual trigger via `workflow_dispatch` (similar to Jenkins manual build)
- Automatic trigger on push to `develop` branch
- Automatic trigger on pull requests to `develop` branch

### 3. **Repository Cloning**
The workflow reads `SonarGitFiles/GIT-BPM_*.txt` files (just like Jenkins) and:
- Clones only the repositories needed for selected applications
- Attempts to use the specified branch (`develop-grs`, etc.)
- Falls back to default branch if specified branch doesn't exist
- Avoids duplicate cloning of shared repositories (like `common.git`)

### 4. **Build Process**
- Reads the same `build_*.properties` files from the `Properties/` folder
- Executes the same Ant builds using `build-single.xml`
- Creates the standalone `GRS_Common.jar`
- Categorizes artifacts into BPM cluster and Service cluster folders

### 5. **Artifact Management**
Uploads build artifacts with proper categorization:
- All EAR files
- Standalone JARs
- BPM cluster artifacts (specific EAR files)
- Service cluster artifacts (remaining EAR files)

## Usage

### Manual Build (via GitHub UI)

1. Go to **Actions** tab in GitHub
2. Select **BPM Build Pipeline** workflow
3. Click **Run workflow**
4. Fill in the inputs:
   - **Application(s) to build**: Enter app names (comma-separated) or "ALL"
   - **Release version**: Enter release (e.g., "grs")
   - **Branch type**: Enter branch type (e.g., "develop")
5. Click **Run workflow**

### Example Inputs

#### Build all applications:
```
app_to_build: ALL
release: grs
branch_type: develop
```

#### Build specific applications:
```
app_to_build: agreement,authorization,findcustomer
release: grs
branch_type: develop
```

### Automatic Builds

The workflow automatically runs when:
- Code is pushed to the `develop` branch
- A pull request is opened targeting the `develop` branch

## Migration from Jenkins

### What's Different?

| Jenkins | GitHub Actions |
|---------|----------------|
| PowerShell script | Bash shell scripts |
| Windows paths (e:\ drive) | Linux paths |
| Network drive mapping (P:) | Artifact upload to GitHub |
| Manual file copying | Artifact upload actions |

### What's the Same?

✅ Same input parameters (AppToBuild, Release, BranchType)  
✅ Same property files (`build_*.properties`)  
✅ Same git file format (`GIT-BPM_*.txt`)  
✅ Same Ant build process  
✅ Same version numbering format  
✅ Same artifact structure  

## Configuration Requirements

### Secrets to Configure

Add these secrets in GitHub repository settings (Settings > Secrets and variables > Actions):

1. **Git Access**:
   - If using HTTPS: `GITHUB_TOKEN` (automatically provided)
   - If using SSH: Add SSH key as `GIT_SSH_KEY` and configure checkout step

2. **Artifactory** (if needed):
   - `ARTIFACTORY_GRS_TOKEN` - for artifact publishing

### Repository Access

Ensure the GitHub Actions runner has access to all repositories listed in `GRS-BPM_GitUrlList.txt`. This may require:
- Personal Access Token with appropriate scopes
- SSH key with read access
- GitHub App installation

## Customization

### Changing Java Version

Edit the `Set up Java` step:
```yaml
- name: Set up Java
  uses: actions/setup-java@v4
  with:
    distribution: 'temurin'
    java-version: '17'  # Change to 8, 11, 17, etc.
```

### Changing Timeout

Edit the `timeout-minutes` value:
```yaml
jobs:
  build:
    timeout-minutes: 180  # Change from 120 to 180
```

### Adding SonarQube Analysis

Add a step after the build:
```yaml
- name: SonarQube Scan
  run: |
    ant -buildfile buildapp_sonar.xml sonar
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

### Deployment Steps

Add deployment steps after artifact upload:
```yaml
- name: Deploy to staging
  if: github.ref == 'refs/heads/develop'
  run: |
    # Your deployment script here
```

## Troubleshooting

### Build Fails to Clone Repositories

**Problem**: Git clone fails with authentication error

**Solution**: 
1. Check that `GH_TOKEN` or SSH keys are properly configured
2. Verify repository URLs in `SonarGitFiles/*.txt` are accessible
3. Check if branch exists (workflow falls back to default branch)

### Ant Build Failures

**Problem**: Ant build fails for specific application

**Solution**:
1. Check that `build_*.properties` file exists in `Properties/` folder
2. Verify `GIT-BPM_*.txt` file exists in `SonarGitFiles/` folder
3. Review build logs for specific errors
4. Ensure all dependencies are cloned

### Missing Artifacts

**Problem**: Expected artifacts are not uploaded

**Solution**:
1. Check build logs for build failures
2. Verify artifact paths in `target/ear/` directory
3. Ensure build completed successfully

## Comparison with Jenkins Script

### Jenkins PowerShell Logic:
```powershell
if(${env:AppToBuild} -eq "ALL") {
  $ScanList=@("ActivatePolicySTPApp","agreement",...)
} else {
  $ScanListTemp=[string]${env:AppToBuild}
  $ScanList=${ScanListTemp}.split(",")
}

foreach($bldapp in $ScanList) {
    e:\was\ant\bin\ant.bat -buildfile build-single.xml ...
}
```

### GitHub Actions Equivalent:
```bash
if [[ "${{ env.APP_TO_BUILD }}" == "ALL" ]]; then
  APPS="ActivatePolicySTPApp,agreement,..."
else
  APPS="${{ env.APP_TO_BUILD }}"
fi

IFS=',' read -ra APP_LIST <<< "${{ steps.apps.outputs.apps }}"
for APP in "${APP_LIST[@]}"; do
  ant -buildfile build-single.xml ...
done
```

## Benefits of GitHub Actions

✅ **Cross-platform**: Runs on Linux, Windows, or macOS  
✅ **Version controlled**: Workflow is stored in repository  
✅ **Cloud native**: No need for dedicated build servers  
✅ **Integrated**: Built into GitHub UI  
✅ **Artifact management**: Automatic artifact storage and retention  
✅ **Matrix builds**: Can easily run parallel builds  
✅ **Better visibility**: Rich build logs and summaries  

## Next Steps

1. **Test the workflow**: Run a manual build with a single application
2. **Validate artifacts**: Download and verify the built EAR/JAR files
3. **Configure secrets**: Add necessary tokens and credentials
4. **Update triggers**: Adjust branch patterns if needed
5. **Add deployment**: Extend workflow with deployment steps
6. **Monitor builds**: Review build times and success rates

## Support

For issues or questions:
- Review build logs in GitHub Actions tab
- Check artifact downloads to verify outputs
- Compare with Jenkins build outputs for validation
