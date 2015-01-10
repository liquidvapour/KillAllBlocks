@echo off
echo --------------------------------------------------------------------------
echo -- building Kill All Blocks                                             --
echo --------------------------------------------------------------------------

set release_path=_release
set love_file=killAllBlocks.love
set love_file_path=.\%release_path%\%love_file%

if not exist .\%release_path% md %release_path%
if exist %love_file_path% del %love_file_path%

zip -r %love_file_path% *

set release_path=
set love_file=
set love_file_path=

echo --------------------------------------------------------------------------
echo -- building Complete                                                    --
echo --------------------------------------------------------------------------
