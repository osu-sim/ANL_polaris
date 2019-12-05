@ECHO OFF

SETLOCAL

IF NOT "%1" == "" (
	set BASEDIR=%1
	call polaris-env.bat %1
) ELSE IF NOT "%POLARIS_DEPS_DIR%" == "" (
	set BASEDIR=%POLARIS_DEPS_DIR%
) ELSE (
	set BASEDIR=C:\opt\polarisdeps
	call polaris-env.bat c:\opt\polarisdeps
)

echo BASEDIR=%BASEDIR%
IF NOT EXIST %BASEDIR% (
	MKDIR %BASEDIR%
)
IF NOT EXIST %BASEDIR%\polaris-env.bat ( COPY polaris-env.bat %BASEDIR% )

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

:: call this because for some goofy reason it fails on the first call - but then works
call find-python.cmd > nul 2>&1
call find-python.cmd > nul 2>&1

:: get our slashes all straightened out :)
set a=%BASEDIR%
set a=%a:/=\%
echo BASEDIR=%a% with slashes fixed
set BASEDIR=%a%

SET LOGDIR=%BASEDIR%\builds
IF NOT EXIST %LOGDIR% ( mkdir %LOGDIR% )
IF EXIST %LOGDIR%\shapelib_build.log ( DEL %LOGDIR%\shapelib_build.log )
IF EXIST %LOGDIR%\freetype_build.log ( DEL %LOGDIR%\freetype_build.log )
IF EXIST %LOGDIR%\wxWidgets_build.log ( DEL %LOGDIR%\wxWidgets_build.log )
IF EXIST %LOGDIR%\agg_build.log ( DEL %LOGDIR%\agg_build.log )
IF EXIST %LOGDIR%\plplot_build.log ( DEL %LOGDIR%\plplot_build.log )
IF EXIST %LOGDIR%\glew_build.log ( DEL %LOGDIR%\glew_build.log )

set BUILD_ERROR=0

cd /D %~dp0
set SHAPELIB_BUILD=0
set ERRORLEVEL=
call %~dp0build-shapelib-1.3.0.cmd %BASEDIR% > %LOGDIR%\shapelib_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of ShapeLib 1.3.0 - FAIL  & set BUILD_ERROR=1)

cd /D %~dp0
set FREETYPE_BUILD=0
set ERRORLEVEL=
call %~dp0build-freetype-2.6.3.cmd %BASEDIR% > %LOGDIR%\freetype_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of FreeType 2.6.3 - FAIL & set BUILD_ERROR=1)

cd /D %~dp0
set WXWIDGETS_BUILD=0
set ERRORLEVEL=
call %~dp0build-wxWidgets-3.1.0.cmd %BASEDIR% > %LOGDIR%\wxWidgets_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of wxWidgets 3.1.0 - FAIL & set BUILD_ERROR=1)

cd /D %~dp0
set AGG_BUILD=0
set ERRORLEVEL=
::call %~dp0build-agg-2.5.cmd %BASEDIR% > %LOGDIR%\agg_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of AGG 2.4 - FAIL & set BUILD_ERROR=1)

cd /D %~dp0
SET PLPLOT_BUILD=0
set ERRORLEVEL=
call %~dp0build-plplot-5.11.1.cmd %BASEDIR% > %LOGDIR%\plplot_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of plPlot 5.11.1 - FAIL & set BUILD_ERROR=1)

cd /D %~dp0
SET GLEW_BUILD=0
set ERRORLEVEL=
call %~dp0build-glew-1.13.0.cmd %BASEDIR% > %LOGDIR%\glew_build.log 2>&1
IF %ERRORLEVEL% NEQ 0 (ECHO Build of Glew 1.13.0 - FAIL & set BUILD_ERROR=1)

:: as a convenience we copy all dll's to a single folder to save on path entries
IF NOT EXIST %BASEDIR%\antares_bin ( mkdir %BASEDIR%\antares_bin )
IF NOT EXIST %BASEDIR%\_antares_bin\Debug ( mkdir %BASEDIR%\antares_bin\Debug )
IF NOT EXIST %BASEDIR%\antares_bin\Release ( mkdir %BASEDIR%\antares_bin\Release )

COPY %BASEDIR%\glew-1.13.0\build_vs2015\bin\Debug\*.dll		%BASEDIR%\antares_bin\Debug
COPY %BASEDIR%\glew-1.13.0\build_vs2015\bin\Release\*.dll	%BASEDIR%\antares_bin\Release

COPY %BASEDIR%\shapelib-1.3.0\lib\shapelib_d.dll			%BASEDIR%\antares_bin\Debug
COPY %BASEDIR%\\shapelib-1.3.0\lib\shapelib.dll				%BASEDIR%\antares_bin\Release

copy %BASEDIR%\wxWidgets-3.1.0\lib\vc_x64_dll\wx*310ud_*.dll %BASEDIR%\antares_bin\Debug
copy %BASEDIR%\wxWidgets-3.1.0\lib\vc_x64_dll\wx*310u_*.dll %BASEDIR%\antares_bin\Release

cd /D %~dp0
call DisplayDate.cmd
IF %BUILD_ERROR% NEQ 0 (ECHO STATUS: FAIL & ENDLOCAL & EXIT /B 1)
ENDLOCAL
ECHO STATUS: SUCCESS

