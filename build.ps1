# Build script for Picoclaw

Write-Host "Picoclaw Build Script" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""

# Create local bin directory if it doesn't exist
$localBinDir = "bin"
if (-not (Test-Path $localBinDir)) {
    New-Item -Path $localBinDir -ItemType Directory -Force | Out-Null
    Write-Host "✓ Created local bin directory" -ForegroundColor Green
}

# Step 1: Build the binary
Write-Host "Step 1: Building picoclaw.exe to bin\..." -ForegroundColor Yellow
# Build from the cmd/picoclaw directory where main.go resides
go build -ldflags="-s -w" -trimpath -o bin\picoclaw.exe ./cmd/picoclaw

if ($?) {
    Write-Host "✓ Build successful!" -ForegroundColor Green
} else {
    Write-Host "✗ Build failed" -ForegroundColor Red
    exit 1
}

# UPX Compression
if (Get-Command upx -ErrorAction SilentlyContinue) {
    Write-Host "Step 2: UPX compressing picoclaw.exe..." -ForegroundColor Yellow
    upx bin\picoclaw.exe
    if ($?) {
        Write-Host "✓ UPX compression successful!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Binary created: bin\picoclaw.exe" -ForegroundColor Cyan
        
        # Show file size
        $fileSize = (Get-Item "bin\picoclaw.exe").Length / 1MB
        Write-Host ("Binary size: {0:N2} MB" -f $fileSize) -ForegroundColor Cyan
    } else {
        Write-Host "✗ UPX compression failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Step 2: UPX compression skipped (upx not found)" -ForegroundColor Yellow
    Write-Host "To install UPX, run: choco install upx  or  scoop install upx" -ForegroundColor Magenta
}

Write-Host ""

# Step 3: Move picoclaw.exe to global bin path
Write-Host "Step 3: Copying picoclaw.exe to global bin path..." -ForegroundColor Yellow
$globalBinPath = "C:\Users\maith\OneDrive\Documents\PowerShell\Tool\bin"
$targetFile = Join-Path $globalBinPath "picoclaw.exe"

# Create global bin directory if it doesn't exist
if (-not (Test-Path $globalBinPath)) {
    New-Item -Path $globalBinPath -ItemType Directory -Force | Out-Null
    Write-Host "✓ Created global bin directory" -ForegroundColor Green
}

# Copy and replace the file
try {
    Copy-Item -Path "bin\picoclaw.exe" -Destination $targetFile -Force
    Write-Host "✓ picoclaw.exe copied to global bin path successfully" -ForegroundColor Green
    Write-Host "  Location: $targetFile" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Failed to copy picoclaw.exe to global bin path" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Done! You can now run: picoclaw" -ForegroundColor Green
