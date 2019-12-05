@ECHO OFF

SETLOCAL

IF NOT "%1" == "" (
	set BASEDIR=%1
) ELSE IF NOT "%POLARIS_DEPS_DIR%" == "" (
	  set BASEDIR=%POLARIS_DEPS_DIR%
) ELSE (
	set BASEDIR=c:\opt\polarisdeps
)

:: get our slashes all straightened out :)
set a=%BASEDIR%
set a=%a:/=\%
echo %a%
set BASEDIR=%a%

IF NOT EXIST %BASEDIR% (mkdir %BASEDIR%)

REM  see if Vsual Studio is already set
SET VCROOT=
IF "%VSINSTALLDIR%" == "" (
	call find-msvc.bat 14
    IF ERRORLEVEL 1 exit /B %ERRORLEVEL%
) ELSE IF NOT "%VisualStudioVersion%" == "14.0" (
	echo "Visual Studio 14.0 (2015) is required"
	exit /B 1
) ELSE IF NOT "%Platform%" == "X64" (
	echo "Visual Studio 14.0 (2015) must be set for X64 platform"
	exit /B 1
)

IF NOT "%VCROOT%" == "" (
    call "%VCROOT%\vcvarsall.bat" amd64
)

:: Download and expand source files
set ZIPFILE=%BASEDIR%\rapidjson-1.1.0.zip
set DESTDIR=%BASEDIR%\rapidjson-1.1.0

echo file=%ZIPFILE%
echo dir=%DESTDIR%

set DEBUG_BUILD=0
set RELEASE_BUILD=0
set BUILD_ERROR=0

set ERRORLEVEL=
cd /D %BASEDIR%
::%~dp0utils\wget --no-check-certificate --show-progress=off -O %ZIPFILE% "https://github.com/miloyip/rapidjson/archive/v1.1.0.zip"
%~dp0utils\wget --show-progress=off -O %ZIPFILE% "https://github.com/miloyip/rapidjson/archive/v1.1.0.zip"
%~dp0utils\unzip -o -q %ZIPFILE%
IF ERRORLEVEL 1 ( ECHO Download and Extract of '%ZIPFILE%' - FAIL  & ECHO STTATUS: FAIL & ENDLOCAL & EXIT /B 1 )

cd /D %~dp0
call DisplayDate.cmd
IF %BUILD_ERROR% NEQ 0 (ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1)
ENDLOCAL
ECHO STATUS: SUCCESS
