# setup_mirror.ps1
# This script sets the PUB_HOSTED_URL environment variable to a mirror to avoid connection timeouts with pub.dev.

$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
Write-Host "✅ Flutter mirror set to https://pub.flutter-io.cn"
Write-Host "🚀 Running flutter pub get..."
flutter pub get
