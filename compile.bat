@echo off

rem  Inno Setup
rem  Copyright (C) 1997-2019 Jordan Russell
rem  Portions by Martijn Laan
rem  For conditions of distribution and use, see LICENSE.TXT.
rem
rem  Batch file to compile the help files and all projects

setlocal

if exist compilesettings.bat goto compilesettingsfound
:compilesettingserror
echo compilesettings.bat is missing or incomplete. It needs to be created
echo with the following line, adjusted for your system:
echo.
echo   set DELPHIXEROOT=C:\Program Files\Embarcadero\RAD Studio\20.0 [Path to Delphi 10.4 Sydney (or later)]
goto failed2

:compilesettingsfound
set DELPHIXEROOT=
call .\compilesettings.bat
if "%DELPHIXEROOT%"=="" goto compilesettingserror

rem -------------------------------------------------------------------------

rem  Compile each project separately because it seems Delphi
rem  carries some settings (e.g. $APPTYPE) between projects
rem  if multiple projects are specified on the command line.

set DELPHIXEDISABLEDWARNINGS=-W-SYMBOL_DEPRECATED -W-SYMBOL_PLATFORM -W-UNSAFE_CAST -W-EXPLICIT_STRING_CAST -W-EXPLICIT_STRING_CAST_LOSS -W-IMPLICIT_INTEGER_CAST_LOSS -W-IMPLICIT_CONVERSION_LOSS
set 

cd Projects
if errorlevel 1 goto exit

cd ISPP
if errorlevel 1 goto failed

echo - ISPP.dpr
"%DELPHIXEROOT%\bin\dcc32.exe" --no-config -NSsystem;system.win;winapi -Q -B -H -W %DELPHIXEDISABLEDWARNINGS% %1 -U"%DELPHIXEROOT%\lib\win32\release" -E..\..\Files -NUDcu ISPP.dpr
if errorlevel 1 goto failed

cd ..

echo - Compil32.dpr
mkdir Dcu\Compil32.dpr 2>nul
"%DELPHIXEROOT%\bin\dcc32.exe" --no-config -NSsystem;system.win;winapi;vcl;vcl.imaging -Q -B -H -W %DELPHIXEDISABLEDWARNINGS% %1 -U"%DELPHIXEROOT%\lib\win32\release;..\Components\UniPs\Source;ISPP" -E..\Files -NUDcu\Compil32.dpr -DPS_MINIVCL;PS_NOGRAPHCONST;PS_PANSICHAR;PS_NOINTERFACEGUIDBRACKETS Compil32.dpr
if errorlevel 1 goto failed

echo - ISCC.dpr
mkdir Dcu\ISCC.dpr 2>nul
"%DELPHIXEROOT%\bin\dcc32.exe" --no-config -NSsystem;system.win;winapi -Q -B -H -W %DELPHIXEDISABLEDWARNINGS% %1 -U"%DELPHIXEROOT%\lib\win32\release;..\Components\UniPs\Source" -E..\Files -NUDcu\ISCC.dpr -DPS_MINIVCL;PS_NOGRAPHCONST;PS_PANSICHAR;PS_NOINTERFACEGUIDBRACKETS ISCC.dpr
if errorlevel 1 goto failed

echo - ISCmplr.dpr
mkdir Dcu\ISCmplr.dpr 2>nul
"%DELPHIXEROOT%\bin\dcc32.exe" --no-config -NSsystem;system.win;winapi;vcl -Q -B -H -W %DELPHIXEDISABLEDWARNINGS% %1 -U"%DELPHIXEROOT%\lib\win32\release;..\Components\UniPs\Source;ISPP;%STCHomeProject%\Library\GraceTimeHandling;%STCHomeProject%\Tests\Serial;%STCHomeProject%\Tests\Serial\Encryption;%BDSCOMPONENTSDIR%\LockBox3\packages\Alexandria\Delphi\Win32\Release" -U"%BDSCOMPONENTSDIR%\jcl\jcl\lib\d28\win32" -E..\Files -NUDcu\ISCmplr.dpr -DPS_MINIVCL;PS_NOGRAPHCONST;PS_PANSICHAR;PS_NOINTERFACEGUIDBRACKETS ISCmplr.dpr
if errorlevel 1 goto failed

echo - SetupLdr.dpr
mkdir Dcu\SetupLdr.dpr 2>nul
"%DELPHIXEROOT%\bin\dcc32.exe" --no-config -NSsystem;system.win;winapi -Q -B -H -W %DELPHIXEDISABLEDWARNINGS% %1 -U"%DELPHIXEROOT%\lib\win32\release" -E..\Files -NUDcu\SetupLdr.dpr -DSETUPLDRPROJ SetupLdr.dpr
if errorlevel 1 goto failed

echo - Setup.dpr
mkdir Dcu\Setup.dpr 2>nul
"%DELPHIXEROOT%\bin\dcc32.exe" --no-config -NSsystem;system.win;winapi;vcl -Q -B -W %DELPHIXEDISABLEDWARNINGS% %1 -U"%DELPHIXEROOT%\lib\win32\release;..\Components\UniPs\Source" -U"%STCHomeProject%\Tests\Serial\Encryption;%BDSCOMPONENTSDIR%\LockBox3\packages\Alexandria\Delphi\Win32\Release" -U"%BDSCOMPONENTSDIR%\jcl\jcl\lib\d28\win32" -E..\Files -NUDcu\Setup.dpr -DSETUPPROJ;PS_MINIVCL;PS_NOGRAPHCONST;PS_PANSICHAR;PS_NOINTERFACEGUIDBRACKETS Setup.dpr
if errorlevel 1 goto failed

echo - Renaming E32 files
cd ..\Files
if errorlevel 1 goto failed
move SetupLdr.exe SetupLdr.e32
if errorlevel 1 goto failed
move Setup.exe Setup.e32
if errorlevel 1 goto failed

echo Success!
cd ..
goto exit

:failed
echo *** FAILED ***
cd ..
:failed2
exit /b 1

:exit
