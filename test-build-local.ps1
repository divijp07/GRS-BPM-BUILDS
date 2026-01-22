# Local Test Build Script
# This simulates the remote build process for testing GitHub Actions workflow

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  BPM Build Test Script (Local)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Display received parameters
Write-Host "Received Parameters:" -ForegroundColor Yellow
Write-Host "  AppToBuild: $env:AppToBuild" -ForegroundColor Green
Write-Host "  Release: $env:Release" -ForegroundColor Green
Write-Host "  BranchType: $env:BranchType" -ForegroundColor Green
Write-Host ""

# Validate parameters
if (-not $env:AppToBuild) {
    Write-Host "ERROR: AppToBuild parameter is missing!" -ForegroundColor Red
    exit 1
}
if (-not $env:Release) {
    Write-Host "ERROR: Release parameter is missing!" -ForegroundColor Red
    exit 1
}
if (-not $env:BranchType) {
    Write-Host "ERROR: BranchType parameter is missing!" -ForegroundColor Red
    exit 1
}

# Generate version number
$verNum = Get-Date -Format "yyyyMMdd-HH:mm"
Write-Host "Generated Version: GRS_BPM_$($env:Release)_$($env:BranchType)_$verNum" -ForegroundColor Cyan
Write-Host ""

# Determine applications to build
if ($env:AppToBuild -eq "ALL") {
    $ScanList = @("agreement", "manageCustomer", "managePolicy", "fundDirection")
    Write-Host "Building ALL applications (showing first 4 for test):" -ForegroundColor Yellow
} else {
    $ScanListTemp = [string]$env:AppToBuild
    $ScanList = $ScanListTemp.Split(",").Trim()
    Write-Host "Building specific applications:" -ForegroundColor Yellow
}

# Simulate build process
$branchName = "$($env:BranchType)-$($env:Release)"
Write-Host "Branch Name: $branchName" -ForegroundColor Cyan
Write-Host ""

$buildSuccess = 0
$buildFailed = 0

foreach ($bldapp in $ScanList) {
    $bldapp = $bldapp.Trim()
    $propFile = "build_${bldapp}.properties"
    $srcFile = "GIT-BPM_${bldapp}.txt"
    
    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    Write-Host "Building: $bldapp" -ForegroundColor White
    Write-Host "  Property File: $propFile" -ForegroundColor Gray
    Write-Host "  Source File: $srcFile" -ForegroundColor Gray
    
    # Check if files exist
    $propPath = "Properties\$propFile"
    $srcPath = "SonarGitFiles\$srcFile"
    
    if ((Test-Path $propPath) -and (Test-Path $srcPath)) {
        Write-Host "  Status: Files found - BUILD SIMULATED" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
        Write-Host "  Result: SUCCESS" -ForegroundColor Green
        $buildSuccess++
    } else {
        Write-Host "  Status: Missing files - SKIPPED" -ForegroundColor Yellow
        if (-not (Test-Path $propPath)) {
            Write-Host "    Missing: $propPath" -ForegroundColor DarkYellow
        }
        if (-not (Test-Path $srcPath)) {
            Write-Host "    Missing: $srcPath" -ForegroundColor DarkYellow
        }
        $buildFailed++
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Build Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Successful: $buildSuccess" -ForegroundColor Green
Write-Host "Skipped: $buildFailed" -ForegroundColor Yellow
Write-Host ""

# Simulate artifact creation
Write-Host "Simulating artifact creation:" -ForegroundColor Yellow
Write-Host "  - GRS_Common.jar" -ForegroundColor Gray
Write-Host "  - EAR files for cluster_bpm" -ForegroundColor Gray
Write-Host "  - EAR files for cluster_svc" -ForegroundColor Gray
Write-Host ""

Write-Host "Test build completed successfully!" -ForegroundColor Green
Write-Host ""

exit 0
