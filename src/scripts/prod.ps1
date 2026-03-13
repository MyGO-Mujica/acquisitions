# Production deployment script for Acquisition App
# This script starts the application in production mode with Neon Cloud Database

Write-Host "[START] Starting Acquisition App in Production Mode" -ForegroundColor Cyan
Write-Host "==============================================="

# Check if .env.production exists
if (-not (Test-Path ".env.production")) {
    Write-Host "[ERROR] .env.production file not found!" -ForegroundColor Red
    Write-Host "   Please create .env.production with your production environment variables." -ForegroundColor Red
    exit 1
}

# Check if Docker is running
try {
    $null = docker info 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Docker not running" }
} catch {
    Write-Host "[ERROR] Docker is not running!" -ForegroundColor Red
    Write-Host "   Please start Docker and try again." -ForegroundColor Red
    exit 1
}

Write-Host "[BUILD] Building and starting production container..." -ForegroundColor Cyan
Write-Host "   - Using Neon Cloud Database (no local proxy)"
Write-Host "   - Running in optimized production mode"
Write-Host ""

# Start production environment
docker compose -f docker-compose.prod.yml up --build -d

# Wait for DB to be ready (basic health check)
Write-Host "[WAIT] Waiting for setup to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Run migrations with Drizzle
Write-Host "[SYNC] Applying latest schema with Drizzle..." -ForegroundColor Cyan
npm run db:migrate

Write-Host ""
Write-Host "[SUCCESS] Production environment started!" -ForegroundColor Green
Write-Host "   Application: http://localhost:3000"
Write-Host "   Logs: docker logs acquisition-app-prod"
Write-Host ""
Write-Host "Useful commands:"
Write-Host "   View logs: docker logs -f acquisition-app-prod"
Write-Host "   Stop app: docker compose -f docker-compose.prod.yml down"