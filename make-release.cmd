@echo off

SET RELEASE_NAME=
IF NOT "%1" == "" (
	set RELEASE_NAME=%1
) ELSE (
	set RELEASE_NAME=test
)

:: temporary fix for RelWithDebInfo
:: at some point it would be nice to have debug info in the 3rd party libs also
::IF NOT EXIST %DEPS_DIR%\bin\RelWithDebInfo ( mkdir %DEPS_DIR%\bin\RelWithDebInfo & xcopy %DEPS_DIR%\bin\Release\* %DEPS_DIR%\bin\RelWithDebInfo\* )

set BUILDDIR=%~dp0\build_vs2015\bin\Release
::IF NOT EXIST %BUILDDIR% ( mkdir %BUILDDIR% )

set RELEASE_DIR=%~dp0\polaris-%RELEASE_NAME%
IF NOT EXIST %RELEASE_DIR% ( mkdir %RELEASE_DIR% )
mkdir %RELEASE_DIR%\bin
xcopy %BUILDDIR%\*.dll %RELEASE_DIR%\bin
xcopy %BUILDDIR%\Integrated_Model.exe %RELEASE_DIR%\bin
rename %RELEASE_DIR%\bin\Integrated_Model.exe polaris.exe

mkdir %RELEASE_DIR%\data
XCOPY /S data %RELEASE_DIR%\data

del %RELEASE_DIR%\data\test_city\!run.bat
echo ..\..\bin\polaris.exe scenario_init.json 1 > %RELEASE_DIR%\data\test_city\!run.bat

zip -r polaris-%RELEASE_NAME%.zip polaris-%RELEASE_NAME%

ENDLOCAL

