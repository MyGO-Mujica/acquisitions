# Development startup script for Acquisition App with Neon Local
# This script starts the application in development mode with Neon Local

Write-Host "[START] Starting Acquisition App in Development Mode" -ForegroundColor Cyan
Write-Host "================================================"

# Check if .env.development exists
if (-not (Test-Path ".env.development")) {
    Write-Host "[ERROR] .env.development file not found!" -ForegroundColor Red
    Write-Host "   Please copy .env.development from the template and update with your Neon credentials." -ForegroundColor Red
    exit 1
}

# Check if Docker is running
try {
    $null = docker info 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Docker not running" }
} catch {
    Write-Host "[ERROR] Docker is not running!" -ForegroundColor Red
    Write-Host "   Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

# Create .neon_local directory if it doesn't exist
$neonLocalPath = ".neon_local"
if (-not (Test-Path $neonLocalPath)) {
    New-Item -ItemType Directory -Force -Path $neonLocalPath | Out-Null
}

# Add .neon_local to .gitignore if not already present
$gitIgnorePath = ".gitignore"
if (Test-Path $gitIgnorePath) {
    if (-not (Select-String -Path $gitIgnorePath -Pattern "\.neon_local/|^\.neon_local$" -Quiet)) {
        Add-Content -Path $gitIgnorePath -Value "`n.neon_local/"
        Write-Host "[OK] Added .neon_local/ to .gitignore" -ForegroundColor Green
    }
}

Write-Host "[BUILD] Building and starting development containers..." -ForegroundColor Cyan
Write-Host "   - Neon Local proxy will create an ephemeral database branch"
Write-Host "   - Application will run with hot reload enabled"
Write-Host ""

# Run migrations with Drizzle
Write-Host "[SYNC] Applying latest schema with Drizzle..." -ForegroundColor Cyan
npm run db:migrate

# Wait for the database to be ready
Write-Host "[WAIT] Waiting for the database to be ready..." -ForegroundColor Yellow
docker compose exec neon-local psql -U neon -d neondb -c 'SELECT 1'

# Start development environment
docker compose -f docker-compose.dev.yml up --build

Write-Host ""
Write-Host "[SUCCESS] Development environment started!" -ForegroundColor Green
Write-Host "   Application: http://localhost:5173"