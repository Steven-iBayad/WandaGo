@echo off
echo Fixing Gradle Java 21 compatibility issue...
echo.

echo Cleaning Gradle cache...
if exist "%USERPROFILE%\.gradle\caches" (
    rmdir /s /q "%USERPROFILE%\.gradle\caches"
    echo Gradle cache cleaned.
) else (
    echo No Gradle cache found.
)

echo.
echo Cleaning Flutter build cache...
flutter clean

echo.
echo Getting dependencies...
flutter pub get

echo.
echo Gradle cache cleaned! Now try building again:
echo flutter build apk --release
echo.
pause











