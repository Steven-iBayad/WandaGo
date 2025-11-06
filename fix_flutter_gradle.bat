@echo off
echo Fixing Flutter Gradle Plugin compatibility issue...
echo.

echo Cleaning all caches...
flutter clean

echo.
echo Cleaning Gradle cache...
if exist "%USERPROFILE%\.gradle\caches" (
    rmdir /s /q "%USERPROFILE%\.gradle\caches"
    echo Gradle cache cleaned.
)

echo.
echo Cleaning Android build cache...
if exist "android\build" (
    rmdir /s /q "android\build"
    echo Android build cache cleaned.
)

if exist "android\app\build" (
    rmdir /s /q "android\app\build"
    echo App build cache cleaned.
)

echo.
echo Getting dependencies...
flutter pub get

echo.
echo ✅ Cache cleaned! Now try building again:
echo flutter build apk --release
echo.
pause











