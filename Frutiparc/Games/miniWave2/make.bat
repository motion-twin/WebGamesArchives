@ECHO Off

rem -- SWFmake
ECHO SWFmake...
IF NOT EXIST swfmake.xml GOTO skipMake
%MOTIONTOOLS%\swfmake\swfmake.exe -f swfmake.xml
if ERRORLEVEL 1 GOTO error
GOTO success

:skipMake
ECHO File not found...
GOTO error

:success
ECHO Done.
start index.html
GOTO end

:error
ECHO Failed !
PAUSE

:end
