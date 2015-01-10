@echo off
echo --------------------------------------------------------------------------
echo -- building Kill All Blocks                                             --
echo --------------------------------------------------------------------------

if not exist .\%release_path% md %release_path%
if exist %love_file_path% del %love_file_path%

zip -r %love_file_path% *

echo --------------------------------------------------------------------------
echo -- building Complete                                                    --
echo --------------------------------------------------------------------------
