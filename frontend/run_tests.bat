@echo off
REM Run specific working tests
echo Running Flutter tests...

echo.
echo Running Home Screen Tests...
flutter test test/ui/screens/home/home_screen_test.dart

echo.
echo Running Map Screen Tests...
flutter test test/ui/screens/map/map_screen_test.dart

echo.
echo Running Booking History Screen Tests...
flutter test test/ui/screens/booking/booking_history_screen_test.dart

echo.
echo Running Simple Test...
flutter test test/simple_test.dart

echo.
echo Test run completed!
pause