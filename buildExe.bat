@echo off
set love_location=.\packages\love\0.9.1-win64

copy /b "%love_location%\love.exe"+"%love_file_path%" "%KAB_bin_path%\KillAllBlocks.exe"
robocopy "%love_location%" "%KAB_bin_path%"

set love_location=