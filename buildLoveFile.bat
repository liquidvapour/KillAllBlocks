@echo off
echo --------------------------------------------------------------------------
echo -- building %love_file_path%
echo --------------------------------------------------------------------------

if not exist .\%KAB_data_path% md %KAB_data_path%
if exist %love_file_path% del %love_file_path%

zip -r %love_file_path% *

echo --------------------------------------------------------------------------
echo -- building Complete                                                    --
echo --------------------------------------------------------------------------
