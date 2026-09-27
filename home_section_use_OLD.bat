@echo off
REM Switches the home screen's mood / water / sleep / tiles section back to the PREVIOUS design.
cd /d "%~dp0lib"
copy /Y "widgets\paid_home_v2\paid_feel_selector.dart.bak_section" "widgets\paid_home_v2\paid_feel_selector.dart"
copy /Y "widgets\paid_home_v2\paid_water_card.dart.bak_section" "widgets\paid_home_v2\paid_water_card.dart"
copy /Y "widgets\paid_home_v2\paid_sleep_card.dart.bak_section" "widgets\paid_home_v2\paid_sleep_card.dart"
copy /Y "widgets\paid_home_v2\paid_stats_row.dart.bak_section" "widgets\paid_home_v2\paid_stats_row.dart"
copy /Y "screens\paid_home_screen_v2.dart.bak_section" "screens\paid_home_screen_v2.dart"
echo.
echo Previous home design is back. Do a hot restart in Flutter.
pause
