@echo off

echo Compiling: loader.xml...
swfmake -f loader.xml
if errorlevel 1 goto error

echo Compiling: swfmake.xml...
swfmake -f swfmake.xml
if errorlevel 1 goto error

echo Done.
start swf\loader.swf
goto end

:error
echo Failed !
goto end

:end
