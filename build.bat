@echo off
call setmainvars.bat

del /s /q %release_path%

call buildLoveFile.bat
call buildExe.bat

call clearmainvars.bat