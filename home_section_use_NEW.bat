@echo off
REM Switches the home screen's mood / water / sleep / tiles section to the NEW design.
cd /d "%~dp0lib"
copy /Y "widgets\paid_home_v2\paid_feel_selector.dart.new_section" "widgets\paid_home_v2\paid_feel_selector.dart"
copy /Y "widgets\paid_home_v2\paid_water_card.dart.new_section" "widgets\paid_home_v2\paid_water_card.dart"
copy /Y "widgets\paid_home_v2\paid_sleep_card.dart.new_section" "widgets\paid_home_v2\paid_sleep_card.dart"
copy /Y "widgets\paid_home_v2\paid_stats_row.dart.new_section" "widgets\paid_home_v2\paid_stats_row.dart"
copy /Y "screens\paid_home_screen_v2.dart.new_section" "screens\paid_home_screen_v2.dart"
echo.
echo New home design is on. Do a hot restart in Flutter.
pause
