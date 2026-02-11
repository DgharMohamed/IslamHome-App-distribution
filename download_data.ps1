# Download Islamic Data Sources
# Run this script to download JSON files from GitHub repositories

$baseDir = "c:\Users\Batman\Desktop\Portfolio Projects\IslamicLibraryApp\islamic_library_flutter\assets\data"

Write-Host "Starting download of Islamic data sources..." -ForegroundColor Green

# Create directories if they don't exist
$dirs = @("$baseDir\quran", "$baseDir\hadith", "$baseDir\adhkar", "$baseDir\nawawi")
foreach ($dir in $dirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Download Adhkar JSON (rn0x)
Write-Host "`nDownloading Adhkar JSON..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rn0x/Adhkar-json/main/adhkar.json" `
        -OutFile "$baseDir\adhkar\adhkar_rn0x.json" -UseBasicParsing
    Write-Host "✓ Adhkar JSON downloaded" -ForegroundColor Green
}
catch {
    Write-Host "✗ Failed to download Adhkar JSON: $_" -ForegroundColor Red
}

# Download Azkar DB (osamayy)
Write-Host "`nDownloading Azkar DB..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/osamayy/azkar-db/master/azkar.json" `
        -OutFile "$baseDir\adhkar\azkar_db.json" -UseBasicParsing
    Write-Host "✓ Azkar DB downloaded" -ForegroundColor Green
}
catch {
    Write-Host "✗ Failed to download Azkar DB: $_" -ForegroundColor Red
}

# Download 40 Hadith Nawawi
Write-Host "`nDownloading 40 Hadith Nawawi..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/osamayy/40-hadith-nawawi-db/master/hadiths.json" `
        -OutFile "$baseDir\nawawi\hadiths.json" -UseBasicParsing
    Write-Host "✓ 40 Hadith Nawawi downloaded" -ForegroundColor Green
}
catch {
    Write-Host "✗ Failed to download 40 Hadith Nawawi: $_" -ForegroundColor Red
}

# Download Hadith Datasets (Sample - Bukhari)
Write-Host "`nDownloading Hadith Dataset (Bukhari)..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/abdelrahmaan/Hadith-Data-Sets/master/Sahih%20al-Bukhari.json" `
        -OutFile "$baseDir\hadith\bukhari.json" -UseBasicParsing
    Write-Host "✓ Bukhari Hadith downloaded" -ForegroundColor Green
}
catch {
    Write-Host "✗ Failed to download Bukhari Hadith: $_" -ForegroundColor Red
}

# Download QuranJSON (Sample - Al-Fatiha)
Write-Host "`nDownloading QuranJSON (Sample Surah)..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/semarketir/quranjson/master/source/surah/surah_1.json" `
        -OutFile "$baseDir\quran\surah_1.json" -UseBasicParsing
    Write-Host "✓ QuranJSON sample downloaded" -ForegroundColor Green
}
catch {
    Write-Host "✗ Failed to download QuranJSON: $_" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "Download process completed!" -ForegroundColor Green
Write-Host "Check the assets/data folder for downloaded files." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
