@echo off
echo ========================================
echo Teacher Connect Uganda - Flutter Setup
echo ========================================
echo.

echo Checking if Flutter is installed...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Flutter is not installed!
    echo.
    echo Please follow these steps:
    echo 1. Download Flutter SDK from: https://flutter.dev/docs/get-started/install/windows
    echo 2. Extract to C:\flutter
    echo 3. Add C:\flutter\bin to your PATH
    echo 4. Restart this terminal and run this script again
    echo.
    pause
    exit /b 1
)

echo Flutter is installed! Checking setup...
echo.

echo Running Flutter Doctor...
flutter doctor

echo.
echo Installing project dependencies...
flutter pub get

echo.
echo Available devices:
flutter devices

echo.
echo Setup complete! To run the app:
echo 1. Start an Android emulator or connect a device
echo 2. Run: flutter run
echo.
pause
