@echo off
REM
REM SETBUILD.CMD - Set build environment for various compilers.
REM Written by Alan Klietz 
REM
REM Copyright (c) 2011, Algin Technology LLC.  Distributed under GNU
REM General Public License version 2.
REM
REM You will need to edit the drive letters and paths to match your
REM particular configuration.
REM
if "%LOCALAPPDATA%"=="" ( set VC8Settings=%USERPROFILE%\Local Settings\Application Data\Microsoft\VisualStudio\8.0\
set VC9Settings=%USERPROFILE%\Local Settings\Application Data\Microsoft\VisualStudio\9.0\
set VC10Settings=%USERPROFILE%\Local Settings\Application Data\Microsoft\MSBuild\v4.0\
) else ( set VC8Settings=%LOCALAPPDATA%\Microsoft\VisualStudio\8.0\
set VC9Settings=%LOCALAPPDATA%\Microsoft\VisualStudio\9.0\
set VC10Settings=%LOCALAPPDATA%\Microsoft\MSBuild\v4.0\
)

rem Required for vc8-vc9 fallthru
set VCSettings=%VC9Settings%

set HomeVC8Settings=E:\home\alan\doc\Visual Studio 2005\Settings\
set HomeVC9Settings=E:\home\alan\doc\Visual Studio 2008\Settings\
set HomeVC10Settings=E:\home\alan\doc\Visual Studio 2010\Settings\

rem Required for vc8-vc9 fallthru
set HomeVCSettings=%HomeVC9Settings%

rem Required for vc8-vc9 fallthru
set VCName=VS2008
set VCVersion=9.0
set VCLib=E:\ae\libvc96

set FrameworkVersion=v3.5
set FrameworkSDKDir=H:\VS2008\SDK\v3.5\

if not "%ProgramFiles(x86)%"=="" ( set REG32=%SystemRoot%\SysWOW64\reg.exe
) else ( set REG32=%SystemRoot%\System32\reg.exe
)

if "%~1"=="/silent" (
	shift /1
	set silent=yes
)
if "%~1"=="/force" (
	shift /1
	set force=yes
)
rem
if "%1"=="restore" goto restore
if "%1"=="%BUILDTOOL%" goto done
set BUILDTOOL=%1
rem
if not "%basepath%"=="" goto nosave
rem
rem Basepath is empty. Save the basepath for later restore
rem 
set basepath=%PATH%
set baseinclude=%INCLUDE%
set baselib=%LIB%
:nosave
rem
set PATH=%basepath%
set INCLUDE=%baseinclude%
set LIB=%baselib%
rem
if "%1"=="msvc16" goto m16
if "%1"=="vc6" goto vc6
if "%1"=="vc8" goto vc8
if "%1"=="vc9" goto vc9
if "%1"=="vc8x64" goto vc8x64
if "%1"=="vc9x64" goto vc9x64
if "%1"=="vc86" goto vc86
if "%1"=="vc96" goto vc96
if "%1"=="vc86x64" goto vc86x64
if "%1"=="vc96x64" goto vc96x64
if "%1"=="vc10" goto vc10
if "%1"=="vc10x64" goto vc10x64
if "%1"=="vc10net35" goto vc10net35
if "%1"=="vc10net35x64" goto vc10net35x64
if "%1"=="vc10net4" goto vc10net4
if "%1"=="vc10net4x64" goto vc10net4x64
if "%1"=="vc106x64" goto vc106x64
if "%1"=="watcom32" goto w32
if "%1"=="watcom32_win32s" goto w32_win32s
if "%1"=="watcom32_os2" goto w32_os2
if "%1"=="watcom32_nt" goto w32_nt
echo Usage: setbuild [vc6,vc8,vc9,vc10,vc8x64,vc9x64,vc10x64,vc86,vc96,vc86x64,vc96x64,vc106x64,vc10net35,vc10net35x64,vc10net4,vc10net4x64,msvc16,watcom32,watcom32_win32s,watcom32_os2,watcom32_nt,restore]
goto done
:restore
if "%basepath%"=="" goto norestore
rem
rem Restore the PATH from the basepath
rem
set BUILDTOOL=
set toolrootdir=
set PATH=%basepath%
set basepath=
set INCLUDE=%baseinclude%
set baseinclude=
set LIB=%baselib%
set baselib=
rem
set Framework35Version=
set FrameworkDir=
set FrameworkDir32=
set FrameworkDir64=
set FrameworkVersion=
set FrameworkVersion32=
set FrameworkVersion64=
set FrameworkSDKDir=
set Platform=
set VSInstallDir=
set VCInstallDir=
set WindowsSdkDir=
set WindowsSdkDir06=
set DevEnvDir=
set LIBPATH=
:norestore
goto done
:m16
set toolrootdir=E:\msvc16
set path=%toolrootdir%\bin;%path%
set include=%toolrootdir%\include;%toolrootdir%\mfc\include
set lib=%toolrootdir%\lib;%toolrootdir%\mfc\lib
if not "%silent%"=="yes" echo Environment variables set for 16-bit Visual C++.
goto done
rem --------------------------------------------------------------------------
:vc6
rem FrameworkXxx is required to use msbuild4 with vc6
rem BUG: MSBuild4 passes too many incompatible args via the CL task. Cant use it
set Framework35Version=v3.5
set FrameworkSDKDir=
set FrameworkVersion=v4.0.30319
set FrameworkVersion32=v4.0.3019
set FrameworkVersion64=
set FrameworkDir=%SystemRoot%\Microsoft.NET\Framework\
set FrameworkDir32=%SystemRoot%\Microsoft.NET\Framework\
set FrameworkDir64=
set WindowsSdkDir=H:\MSSDK06\
set WindowsSdkDir06=
set DevEnvDir=
set Platform=
set AMD64=
set VSInstallDir=G:\DevStudio\
set VCInstallDir=%VSInstallDir%VC98\
set PATH=%WindowsSdkDir%bin;%WindowsSdkDir%bin\winnt;%FrameworkDir%%FrameworkVersion%;%FrameworkDir%%Framework35Version%;%PATH%;%VSInstallDir%Common\MSDev98\Bin;%VSInstallDir%Common\Tools;%VCInstallDir%bin
set LIB=%WindowsSdkDir%lib;H:\DDK\7100\lib\atl\i386;%VCInstallDir%mfc\lib;%VCInstallDir%lib;%LIB%;%FrameworkDir%%FrameworkVersion%;%FrameworkDir%%Framework35Version%
rem set LIB=%LIB%;E:\ae\libvc96;H:\MSSDK09\lib;%FrameworkSDKDir%lib;H:\DDK\7100\lib\atl\i386;H:\DDK\7100\lib\mfc\i386;H:\DDK\7100\lib\crt\i386;H:\DDK\7100\lib\atl\i386
set LIBPATH=%FrameworkDir%%FrameworkVersion%;%FrameworkDir%%Framework35Version%
set INCLUDE=%WindowsSdkDir%include;%WindowsSdkDir%include\atl;%WindowsSdkDir%include\mfc;%WindowsSdkDir%include\crt;%INCLUDE%
rem set INCLUDE=%WindowsSdkDir%include;%INCLUDE%;%VCInstallDir%atl\include;%VCInstallDir%mfc\include;%VCInstallDir%include
set StudioDir=
rem
if not "%silent%"=="yes" echo Environment varibles set for Visual Studio 6.
goto done
rem --------------------------------------------------------------------------
:vc8
set VCSettings=%VC8Settings%
set HomeVCSettings=%HomeVC8Settings%
set VCName=VS2005
set VCVersion=8.0
set FrameworkVersion=v2.0.50727
set FrameworkSDKDir=H:\VS2005\SDK\v2.0\
:vc9
set WindowsSdkDir=H:\MSSDK09\
set VCLib=
set AMD64=
REM
REM Set the build environment for Visual Studio 200x (VC9), target 32-bit x86
REM
set FrameworkDir=%SystemRoot%\Microsoft.NET\Framework\
REM 
REM Need path %FrameworkDir%%FrameworkVersion% for gac, caspol, ilasm, regasm
REM
set VSInstallDir=H:\%VCName%\
set VCInstallDir=%VSInstallDir%VC\
set PATH=%WindowsSdkDir%bin;%FrameworkSDKDir%Bin;%VCInstallDir%bin;%VSInstallDir%Common7\Tools;%VSInstallDir%Common7\IDE;%VCInstallDir%vcpackages;%FrameworkDir%%FrameworkVersion%;%PATH%
REM Use x64 versions of tools if running on x64
if not "%ProgramFiles(x86)%"=="" set PATH=%WindowsSdkDir%bin\X64;%PATH%
set LIB=%LIB%;%WindowsSdkDir%lib;%FrameworkSDKDir%lib;%VCInstallDir%lib;%VCInstallDir%atlmfc\lib
set LIBPATH=%FrameworkDir%;%FrameworkDir%%FrameworkVersion%;%VCInstallDir%lib;%VCInstallDir%atlmfc\lib
set INCLUDE=%INCLUDE%;%WindowsSdkDir%include;%FrameworkSDKDir%include;%VCInstallDir%include;%VCInstallDir%atlmfc\include
REM
%REG32% ADD "HKLM\Software\Microsoft\VisualStudio\%VCVersion%" /v "Source Directories" /d "H:\%VCName%\VC\crt\src\;H:\%VCName%\VC\atlmfc\src\mfc\;H:\%VCName%\VC\atlmfc\src\atl\;H:\%VCNAME%\VC\atlmfc\include\\" /f
if "%force%"=="yes" goto force_vc9
cmp -s "%VCSettings%VCComponents_Alan_vc9.dat" "%VCSettings%VCComponents.dat"
if %ERRORLEVEL% EQU 0 goto done
:force_vc9
cp "%VCSettings%VCComponents_Alan_vc9.dat" "%VCSettings%VCComponents.dat"
rem BUG: Race condition causes Exit to occur before /ResetSettings
rem start /wait devenv.exe /ResetSettings "%HomeVCSettings%Alan_vc9.vssettings" /Command Exit
rem python "%HomeVCSettings%SpliceSettings.py" %1
if not "%silent%"=="yes" echo Environment varibles set for %VCName%, target x86.
goto done
rem --------------------------------------------------------------------------
:vc8x64
set VCSettings=%VC8Settings%
set HomeVCSettings=%HomeVC8Settings%
set VCName=VS2005
set VCVersion=8.0
set FrameworkVersion=v2.0.50727
set FrameworkSDKDir=H:\VS2005\SDK\v2.0\
:vc9x64
set WindowsSdkDir=H:\MSSDK09\
set VCLib=
set AMD64=1
REM
REM Set the build environment for VC9, target AMD64/EMT64 (x64), use VC9 DLLs
REM
set FrameworkDir=%SystemRoot%\Microsoft.NET\Framework64\
REM 
REM Need path %FrameworkDir%%FrameworkVersion% for gac, caspol, ilasm, regasm
REM
set VSInstallDir=H:\%VCName%\
set VCInstallDir=%VSInstallDir%VC\
set PATH=%WindowsSdkDir%bin;%FrameworkSDKDir%Bin;%VCInstallDir%bin\x86_amd64;%VCInstallDir%bin;%VSInstallDir%Common7\Tools;%VSInstallDir%Common7\IDE;%VCInstallDir%vcpackages;%FrameworkDir%%FrameworkVersion%;%PATH%
REM Use x64 versions of tools if running on x64
if not "%ProgramFiles(x86)%"=="" set PATH=%WindowsSdkDir%bin\X64;%PATH%
set LIB=%WindowsSdkDir%lib\x64;%FrameworkSDKDir%lib\amd64;%VCInstallDir%lib\amd64;%VCInstallDir%atlmfc\lib\amd64
set LIBPATH=%FrameworkDir%;%FrameworkDir%%FrameworkVersion%;%VCInstallDir%lib\amd64;%VCInstallDir%atlmfc\lib\amd64
set INCLUDE=%WindowsSdkDir%include;%FrameworkSDKDir%include;%VCInstallDir%include;%VCInstallDir%atlmfc\include;%INCLUDE%
REM
%REG32% ADD "HKLM\Software\Microsoft\VisualStudio\%VCVersion%" /v "Source Directories" /d "H:\%VCName%\VC\crt\src\;H:\%VCName%\VC\atlmfc\src\mfc\;H:\%VCName%\VC\atlmfc\src\atl\;H:\%VCNAME%\VC\atlmfc\include\\" /f
if "%force%"=="yes" goto force_vc8x64
cmp -s "%VCSettings%VCComponents_Alan_vc9.dat" "%VCSettings%VCComponents.dat"
if %ERRORLEVEL% EQU 0 goto done
:force_vc8x64
cp "%VCSettings%VCComponents_Alan_vc9.dat" "%VCSettings%VCComponents.dat"
rem BUG: Race condition causes Exit to occur before /ResetSettings
rem start /wait devenv.exe /ResetSettings "%HomeVCSettings%Alan_vc9.vssettings" /Command Exit
rem python "%HomeVCSettings%SpliceSettings.py" %1
if not "%silent%"=="yes" echo Environment varibles set for %VCName%, target x64
goto done
rem --------------------------------------------------------------------------
:vc86
set VCSettings=%VC8Settings%
set HomeVCSettings=%HomeVC8Settings%
set VCName=VS2005
set VCVersion=8.0
set VCLib=E:\ae\libvc86
set FrameworkVersion=v2.0.50727
set FrameworkSDKDir=H:\VS2005\SDK\v2.0\
:vc96
set WindowsSdkDir=H:\MSSDK09\
set AMD64=
REM
REM Set the build environment for Visual Studio 200x (VC9), target 32-bit x86
REM Use backward-compatible DLLs (MFC42, MSVCRT)
REM
REM Uses Visual Studio 200x (VC9) compiler, but with VC6 includes and libraries.
REM The VC6 Includes were updated for 32/64-bit in \DDK\7100\
REM
set FrameworkDir=%SystemRoot%\Microsoft.NET\Framework\
REM 
REM Need path %FrameworkDir%%FrameworkVersion% for gac, caspol, ilasm, regasm
REM
set VSInstallDir=H:\%VCName%\
set VCInstallDir=%VSInstallDir%VC\
set PATH=%WindowsSdkDir%bin;%FrameworkSDKDir%Bin;%VCInstallDir%bin;%VSInstallDir%Common7\Tools;%VSInstallDir%Common7\IDE;%VCInstallDir%vcpackages;%FrameworkDir%%FrameworkVersion%;%PATH%
if not "%ProgramFiles(x86)%"=="" set PATH=%WindowsSdkDir%bin\X64;%WindowsSdkDir%bin\win64\X64;%PATH%
rem
set StudioDir=G:\DevStudio
set LIB=%LIB%;%VCLib%;%WindowsSdkDir%lib;%FrameworkSDKDir%lib;H:\DDK\7100\lib\atl\i386;%StudioDir%\VC98\mfc\lib;%StudioDir%\VC98\lib
rem Cannot use the following - missing H:\DDK\7100\bin\msvcrtd.dll
rem set LIB=%LIB%;%VCLib%;%WindowsSdkDir%lib;%FrameworkSDKDir%lib;H:\DDK\7100\lib\crt\i386;H:\DDK\7100\lib\atl\i386;H:\DDK\7100\lib\mfc\i386
set LIBPATH=%FrameworkDir%%FrameworkVersion%
set INCLUDE=E:\ae\atl30;%WindowsSdkDir%include;H:\DDK\7100\inc\crt;H:\DDK\7100\inc\mfc42;H:\DDK\7100\inc\api\crt\stl60;%FrameworkSDKDir%include;%INCLUDE%
set StudioDir=
REM
%REG32% ADD "HKLM\Software\Microsoft\VisualStudio\%VCVersion%" /v "Source Directories" /d "E:\ae\atl30\;G:\DevStudio\VC98\crt\src\;G:\DevStudio\VC98\mfc\src\;H:\DDK\7100\inc\mfc42\;H:\DDK\7100\inc\api\crt\stl60\\" /f
if "%force%"=="yes" goto force_vc86
cmp -s "%VCSettings%VCComponents_Alan_vc96.dat" "%VCSettings%VCComponents.dat"
if %ERRORLEVEL% EQU 0 goto done
:force_vc86
cp "%VCSettings%VCComponents_Alan_vc96.dat" "%VCSettings%VCComponents.dat"
rem BUG: Race condition causes Exit to occur before /ResetSettings
rem start /wait devenv.exe /ResetSettings "%HomeVCSettings%Alan_vc96.vssettings" /Command Exit
rem python "%HomeVCSettings%SpliceSettings.py" %1
if not "%silent%"=="yes" echo Environment varibles set for %VCNAME% w/VC6 include and lib
goto done
rem --------------------------------------------------------------------------
:vc86x64
REM
REM Set the build environment for VC8 DevEnv.exe and vcbuild.exe, but
REM target backward-compatible 64-bit x64 (W2K3 x64 and XP x64).
REM
REM Uses the March 2006 Platform SDK cross-compiler 
REM H:\MSSDK06\bin\win64\x86\AMD64\cl.exe (version 14.00.40310) with
REM the VC6 includes and MSSDK06 libs.  The VC6 includes are updated
REM for 32/64-bit in \DDK\7100\.
REM
set VCSettings=%VC8Settings%
set HomeVCSettings=%HomeVC8Settings%
set VCName=VS2005
set VCVersion=8.0
set FrameworkVersion=v2.0.50727
set FrameworkSDKDir=H:\VS2005\SDK\v2.0\
:vc96x64
REM
REM Set the build environment for VC9 DevEnv.exe and vcbuild.exe, but
REM target backward-compatible 64-bit x64 (W2K3 x64 and XP x64).
REM
REM Uses the March 2006 Platform SDK cross-compiler 
REM H:\MSSDK06\bin\win64\x86\AMD64\cl.exe (version 14.00.40310) with
REM the VC6 includes and MSSDK06 libs.  The VC6 includes are updated
REM for 32/64-bit in \DDK\7100\.
REM
set WindowsSdkDir06=H:\MSSDK06\
set WindowsSdkDir=H:\MSSDK09\
set VCLib=
set AMD64=1
set FrameworkDir=%SystemRoot%\Microsoft.NET\Framework64\
set VSInstallDir=H:\%VCName%\
set VCInstallDir=%VSInstallDir%VC\
set PATH=%WindowsSdkDir06%bin;%FrameworkSDKDir%Bin;%WindowsSdkDir06%bin\win64\x86\AMD64;%VCInstallDir%bin;%VSInstallDir%Common7\Tools;%VSInstallDir%Common7\IDE;%VCInstallDir%vcpackages;%FrameworkDir%%FrameworkVersion%;%PATH%
rem Cannot use the VS200x compiler because it generates unref symbols
rem set PATH=%WindowsSdkDir%bin;%FrameworkSDKDir%Bin;%VCInstallDir%bin\x86_amd64;%VCInstallDir%bin;%VSInstallDir%Common7\Tools;%VSInstallDir%Common7\IDE;%VCInstallDir%vcpackages;%FrameworkDir%%FrameworkVersion%;%PATH%
REM Use x64 versions of tools if running on x64
if not "%ProgramFiles(x86)%"=="" set PATH=%WindowsSdkDir%bin\X64;%PATH%
rem
set LIB=%WindowsSdkDir06%lib\amd64;%FrameworkSDKDir%lib\amd64;%WindowsSdkDir06%lib\amd64\atlmfc
rem Cannot use the following - missing H:\DDK\7100\bin\amd64\msvcrtd.dll
rem set LIB=%LIB%;%VCLib%;%WindowsSdkDir%lib;%FrameworkSDKDir%lib;H:\DDK\7100\lib\crt\amd64;H:\DDK\7100\lib\atl\amd64;H:\DDK\7100\lib\mfc\amd64
set LIBPATH=%FrameworkDir%%FrameworkVersion%
set INCLUDE=%WindowsSdkDir%include;%WindowsSdkDir06%include\mfc;%WindowsSdkDir06%include\atl;%WindowsSdkDir06%include\crt;%FrameworkSDKDir%include;%INCLUDE%
rem Cannot use the following
rem set INCLUDE=E:\ae\atl30;%WindowsSdkDir%include;H:\DDK\7100\inc\crt;H:\DDK\7100\inc\mfc42;H:\DDK\7100\inc\api\crt\stl60;%FrameworkSDKDir%include;%INCLUDE%
REM
%REG32% ADD "HKLM\Software\Microsoft\VisualStudio\%VCVersion%" /v "Source Directories" /d "%WindowsSdkDir06%src\crt\;%WindowsSdkDir06%src\mfc\;%WindowsSdkDir06%include\crt\;%WindowsSdkDir06%include\mfc\;%WindowsSdkDir06%include\atl\\" /f
if "%force%"=="yes" goto force_vc96x64
cmp -s "%VCSettings%VCComponents_Alan_vc96.dat" "%VCSettings%VCComponents.dat"
if %ERRORLEVEL% EQU 0 goto done
:force_vc96x64
cp "%VCSettings%VCComponents_Alan_vc96.dat" "%VCSettings%VCComponents.dat"
rem BUG: Race condition causes Exit to occur before /ResetSettings
rem start /wait devenv.exe /ResetSettings "%HomeVCSettings%Alan_vc96.vssettings" /Command Exit
rem python "%HomeVCSettings%SpliceSettings.py" %1
if not "%silent%"=="yes" echo Environment varibles set for %VCName%, target x64, with MSVCRT.DLL compiler and libs
goto done
rem --------------------------------------------------------------------------
:vc10net4
REM
REM Set the build environment for .NET 4 on x86 (vc10net4)
REM
set VCSettings=%VC10Settings%
set HomeVCSettings=%HomeVC10Settings%
set VCName=VS2010
set VCVersion=10.0
set VCLib=
set AMD64=
set Framework35Version=v3.5
set FrameworkSDKDir=
set FrameworkVersion=v4.0.30319
set FrameworkVersion32=v4.0.30319
set FrameworkVersion64=
set FrameworkDir=%SystemRoot%\Microsoft.NET\Framework\
set FrameworkDir32=%SystemRoot%\Microsoft.NET\Framework\
set FrameworkDir64=
rem set WindowsSdkDir=C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\
set WindowsSdkDir=H:\MSSDK10\
set VSInstallDir=H:\%VCName%\
set VCInstallDir=%VSInstallDir%VC\
set DevEnvDir=%VSInstallDir%Common7\IDE\
rem
set PATH=%VSInstallDir%VSTSDB\Deploy;%DevEnvDir%;%VCInstallDir%bin;%VSInstallDir%Common7\Tools;%FrameworkDir%%FrameworkVersion%;%FrameworkDir%%Framework35Version%;%VCInstallDir%VCPackages;%VSInstallDir%Team Tools\Performance Tools;%WindowsSdkDir%bin\NETFX 4.0 Tools;%WindowsSdkDir%bin;%PATH%
REM Use x64 versions of tools if running on x64
REM BUG: The MSBUILD4 Tracker requires x86, else TRK0002 error.
rem if not "%ProgramFiles(x86)%"=="" set PATH=%WindowsSdkDir%bin\x64;%WindowsSdkDir%bin\NETFX 4.0 Tools\x64;%PATH%
set LIB=%LIB%;%WindowsSdkDir%lib;%VCInstallDir%lib;%VCInstallDir%atlmfc\lib
set LIBPATH=%FrameworkDir%%FrameworkVersion%;%FrameworkDir%%Framework35Version%;%VCInstallDir%lib;%VCInstallDir%atlmfc\lib
set INCLUDE=%INCLUDE%;%WindowsSdkDir%include;%VCInstallDir%include;%VCInstallDir%atlmfc\include
REM
%REG32% ADD "HKLM\Software\Microsoft\VisualStudio\%VCVersion%" /v "Source Directories" /d "%VCInstallDir%crt\src\;%VCInstallDir%atlmfc\src\mfc\;%VCInstallDir%atlmfc\src\mfcm\;%VCInstallDir%atlmfc\src\atl\;%VCInstallDir%atlmfc\include\\" /f
if "%force%"=="yes" goto force_vc10net4
cmp -s "%VCSettings%Microsoft.Cpp.Win32.user_Alan_vc10Net4.props" "%VCSettings%Microsoft.Cpp.Win32.user.props"
if %ERRORLEVEL% EQU 0 goto done
:force_vc10net4
cp "%VCSettings%Microsoft.Cpp.Win32.user_Alan_vc10Net4.props" "%VCSettings%Microsoft.Cpp.Win32.user.props"
if not "%silent%"=="yes" echo Environment varibles set for %VCName% .NET 4, target x86.
goto done
rem --------------------------------------------------------------------------
:vc10net4x64
REM
REM Set the build environment for .NET 4 on x64 (vc10net4x64)
REM
set VCSettings=%VC10Settings%
set HomeVCSettings=%HomeVC10Settings%
set VCName=VS2010
set VCVersion=10.0
set VCLib=
set Framework35Version=v3.5
set FrameworkSDKDir=
set FrameworkVersion=v4.0.30319
set FrameworkVersion32=
set FrameworkVersion64=v4.0.30319
set FrameworkDir=%SystemRoot%\Microsoft.NET\Framework64\
set FrameworkDir32=
set FrameworkDir64=%SystemRoot%\Microsoft.NET\Framework64\
rem set WindowsSdkDir=C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\
set WindowsSdkDir=H:\MSSDK10\
set VSInstallDir=H:\%VCName%\
set VCInstallDir=%VSInstallDir%VC\
set DevEnvDir=%VSInstallDir%Common7\IDE\
set Platform=X64
rem
set PATH=%VCInstallDir%bin\amd64;%VSInstallDir%VSTSDB\Deploy;%DevEnvDir%;%VCInstallDir%bin;%VSInstallDir%Common7\Tools;%FrameworkDir%%FrameworkVersion%;%FrameworkDir%%Framework35Version%;%VCInstallDir%VCPackages;%VSInstallDir%Team Tools\Performance Tools\x64;%VSInstallDir%Team Tools\Performance Tools;%WindowsSdkDir%bin\NETFX 4.0 Tools\x64;%WindowsSdkDir%bin\x64;%WindowsSdkDir%bin;%PATH%
set LIB=%LIB%;%WindowsSdkDir%lib\x64;%VCInstallDir%lib\amd64;%VCInstallDir%atlmfc\lib\amd64
set LIBPATH=%FrameworkDir%%FrameworkVersion%;%FrameworkDir%%Framework35Version%;%VCInstallDir%lib\amd64;%VCInstallDir%atlmfc\lib\amd64
set INCLUDE=%INCLUDE%;%WindowsSdkDir%include;%VCInstallDir%include;%VCInstallDir%atlmfc\include
REM
%REG32% ADD "HKLM\Software\Microsoft\VisualStudio\%VCVersion%" /v "Source Directories" /d "%VCInstallDir%crt\src\;%VCInstallDir%atlmfc\src\mfc\;%VCInstallDir%atlmfc\src\mfcm\;%VCInstallDir%atlmfc\src\atl\;%VCInstallDir%atlmfc\include\\" /f
if "%force%"=="yes" goto force_vc10net4x64
cmp -s "%VCSettings%Microsoft.Cpp.x64.user_Alan_vc10Net4.props" "%VCSettings%Microsoft.Cpp.x64.user.props"
if %ERRORLEVEL% EQU 0 goto done
:force_vc10net4x64
cp "%VCSettings%Microsoft.Cpp.x64.user_Alan_vc10Net4.props" "%VCSettings%Microsoft.Cpp.x64.user.props"
if not "%silent%"=="yes" echo Environment varibles set for %VCName% .NET 4, target x64.
goto done
rem --------------------------------------------------------------------------
:vc10net35
REM
REM Set the build environment for .NET 3.5 on x86 (vc10net35)
REM
set VCSettings=%VC10Settings%
set HomeVCSettings=%HomeVC10Settings%
set VCName=VS2010
set VCVersion=10.0
set VCLib=
set AMD64=
set Framework35Version=
set FrameworkSDKDir=
set FrameworkVersion=v3.5
set FrameworkVersion32=v3.5
set FrameworkVersion64=
set FrameworkDir=%SystemRoot%\Microsoft.NET\Framework\
set FrameworkDir32=%SystemRoot%\Microsoft.NET\Framework\
set FrameworkDir64=
rem set WindowsSdkDir=C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\
set WindowsSdkDir=H:\MSSDK10\
set VSInstallDir=H:\%VCName%\
set VCInstallDir=%VSInstallDir%VC\
set DevEnvDir=%VSInstallDir%Common7\IDE\
rem
set PATH=%VSInstallDir%VSTSDB\Deploy;%DevEnvDir%;%VCInstallDir%bin;%VSInstallDir%Common7\Tools;%FrameworkDir%%FrameworkVersion%;%VCInstallDir%VCPackages;%VSInstallDir%Team Tools\Performance Tools;%WindowsSdkDir%bin;%PATH%
REM Use x64 versions of tools if running on x64
REM BUG: The MSBUILD4 Tracker requires x86, else TRK0002 error.
rem if not "%ProgramFiles(x86)%"=="" set PATH=%WindowsSdkDir%bin\x64;%PATH%
set LIB=%LIB%;%WindowsSdkDir%lib;%VCInstallDir%lib;%VCInstallDir%atlmfc\lib
set LIBPATH=%FrameworkDir%%FrameworkVersion%;%VCInstallDir%lib;%VCInstallDir%atlmfc\lib
set INCLUDE=%INCLUDE%;%WindowsSdkDir%include;%VCInstallDir%include;%VCInstallDir%atlmfc\include
REM
%REG32% ADD "HKLM\Software\Microsoft\VisualStudio\%VCVersion%" /v "Source Directories" /d "%VCInstallDir%crt\src\;%VCInstallDir%atlmfc\src\mfc\;%VCInstallDir%atlmfc\src\mfcm\;%VCInstallDir%atlmfc\src\atl\;%VCInstallDir%atlmfc\include\\" /f
if "%force%"=="yes" goto force_vc10net35
cmp -s "%VCSettings%Microsoft.Cpp.Win32.user_Alan_vc10Net35.props" "%VCSettings%Microsoft.Cpp.Win32.user.props"
if %ERRORLEVEL% EQU 0 goto done
:force_vc10net35
cp "%VCSettings%Microsoft.Cpp.Win32.user_Alan_vc10Net35.props" "%VCSettings%Microsoft.Cpp.Win32.user.props"
if not "%silent%"=="yes" echo Environment varibles set for %VCName% .NET 3.5, target x86.
goto done
rem --------------------------------------------------------------------------
:vc10net35x64
REM
REM Set the build environment for .NET 3.5 on x64 (vc10net35x64)
REM
set VCSettings=%VC10Settings%
set HomeVCSettings=%HomeVC10Settings%
set VCName=VS2010
set VCVersion=10.0
set VCLib=
set Framework35Version=
set FrameworkSDKDir=
set FrameworkVersion=v3.5
set FrameworkVersion32=
set FrameworkVersion64=v3.5
set FrameworkDir=%SystemRoot%\Microsoft.NET\Framework64\
set FrameworkDir32=
set FrameworkDir64=%SystemRoot%\Microsoft.NET\Framework64\
rem set WindowsSdkDir=C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\
set WindowsSdkDir=H:\MSSDK10\
set VSInstallDir=H:\%VCName%\
set VCInstallDir=%VSInstallDir%VC\
set DevEnvDir=%VSInstallDir%Common7\IDE\
set Platform=X64
rem
set PATH=%VCInstallDir%bin\amd64;%VSInstallDir%VSTSDB\Deploy;%DevEnvDir%;%VCInstallDir%bin;%VSInstallDir%Common7\Tools;%FrameworkDir%%FrameworkVersion%;%VCInstallDir%VCPackages;%VSInstallDir%Team Tools\Performance Tools\x64;%VSInstallDir%Team Tools\Performance Tools;%WindowsSdkDir%bin\x64;%WindowsSdkDir%bin;%PATH%
set LIB=%LIB%;%WindowsSdkDir%lib\x64;%VCInstallDir%lib\amd64;%VCInstallDir%atlmfc\lib\amd64
set LIBPATH=%FrameworkDir%%FrameworkVersion%;%VCInstallDir%lib\amd64;%VCInstallDir%atlmfc\lib\amd64
set INCLUDE=%INCLUDE%;%WindowsSdkDir%include;%VCInstallDir%include;%VCInstallDir%atlmfc\include
REM
%REG32% ADD "HKLM\Software\Microsoft\VisualStudio\%VCVersion%" /v "Source Directories" /d "%VCInstallDir%crt\src\;%VCInstallDir%atlmfc\src\mfc\;%VCInstallDir%atlmfc\src\mfcm\;%VCInstallDir%atlmfc\src\atl\;%VCInstallDir%atlmfc\include\\" /f
if "%force%"=="yes" goto force_vc10net35x64
cmp -s "%VCSettings%Microsoft.Cpp.x64.user_Alan_vc10Net35.props" "%VCSettings%Microsoft.Cpp.x64.user.props"
if %ERRORLEVEL% EQU 0 goto done
:force_vc10net4x64
cp "%VCSettings%Microsoft.Cpp.x64.user_Alan_vc10Net35.props" "%VCSettings%Microsoft.Cpp.x64.user.props"
if not "%silent%"=="yes" echo Environment varibles set for %VCName% .NET 3.5, target x64.
goto done
rem --------------------------------------------------------------------------
:vc10
REM
REM Set the build environment for VC10 on x86
REM
set VCSettings=%VC10Settings%
set HomeVCSettings=%HomeVC10Settings%
set VCName=VS2010
set VCVersion=10.0
set VCLib=
set AMD64=
set Framework35Version=v3.5
set FrameworkSDKDir=
set FrameworkVersion=v4.0.30319
set FrameworkVersion32=v4.0.30319
set FrameworkVersion64=
set FrameworkDir=%SystemRoot%\Microsoft.NET\Framework\
set FrameworkDir32=%SystemRoot%\Microsoft.NET\Framework\
set FrameworkDir64=
set WindowsSdkDir=H:\MSSDK10\
set VSInstallDir=H:\%VCName%\
set VCInstallDir=%VSInstallDir%VC\
set DevEnvDir=%VSInstallDir%Common7\IDE\
rem
set PATH=%VSInstallDir%VSTSDB\Deploy;%DevEnvDir%;%VCInstallDir%bin;%VSInstallDir%Common7\Tools;%FrameworkDir%%FrameworkVersion%;%FrameworkDir%%Framework35Version%;%VCInstallDir%VCPackages;%VSInstallDir%Team Tools\Performance Tools;%WindowsSdkDir%bin\NETFX 4.0 Tools;%WindowsSdkDir%bin;%PATH%
REM Use x64 versions of tools if running on x64
REM BUG: The MSBUILD4 Tracker requires x86, else TRK0002 error.
rem if not "%ProgramFiles(x86)%"=="" set PATH=%WindowsSdkDir%bin\x64;%WindowsSdkDir%bin\NETFX 4.0 Tools\x64;%PATH%
set LIB=%LIB%;%WindowsSdkDir%lib;%VCInstallDir%lib;%VCInstallDir%atlmfc\lib
set LIBPATH=%FrameworkDir%%FrameworkVersion%;%FrameworkDir%%Framework35Version%;%VCInstallDir%lib;%VCInstallDir%atlmfc\lib
set INCLUDE=%INCLUDE%;%WindowsSdkDir%include;%VCInstallDir%include;%VCInstallDir%atlmfc\include
REM
%REG32% ADD "HKLM\Software\Microsoft\VisualStudio\%VCVersion%" /v "Source Directories" /d "%VCInstallDir%crt\src\;%VCInstallDir%atlmfc\src\mfc\;%VCInstallDir%atlmfc\src\mfcm\;%VCInstallDir%atlmfc\src\atl\;%VCInstallDir%atlmfc\include\\" /f
if "%force%"=="yes" goto force_vc10
cmp -s "%VCSettings%Microsoft.Cpp.Win32.user_Alan_vc10.props" "%VCSettings%Microsoft.Cpp.Win32.user.props"
if %ERRORLEVEL% EQU 0 goto done
:force_vc10
cp "%VCSettings%Microsoft.Cpp.Win32.user_Alan_vc10.props" "%VCSettings%Microsoft.Cpp.Win32.user.props"
rem BUG: Race condition causes Exit to occur before /ResetSettings
rem start /wait devenv.exe /ResetSettings "%HomeVCSettings%Alan_vc10.vssettings" /Command Exit
rem python "%HomeVCSettings%SpliceSettings.py" %1
rem See C:\lbin\OLD\SpliceSettings.py -- Good example of XML parsing in Python
if not "%silent%"=="yes" echo Environment varibles set for %VCName%, target x86.
goto done
rem --------------------------------------------------------------------------
:vc10x64
REM
REM Set the build environment for VC10 on x64
REM
set VCSettings=%VC10Settings%
set HomeVCSettings=%HomeVC10Settings%
set VCName=VS2010
set VCVersion=10.0
set VCLib=
set Framework35Version=v3.5
set FrameworkSDKDir=
set FrameworkVersion=v4.0.30319
set FrameworkVersion32=
set FrameworkVersion64=v4.0.30319
set FrameworkDir=%SystemRoot%\Microsoft.NET\Framework64\
set FrameworkDir32=
set FrameworkDir64=%SystemRoot%\Microsoft.NET\Framework64\
set WindowsSdkDir=H:\MSSDK10\
set VSInstallDir=H:\%VCName%\
set VCInstallDir=%VSInstallDir%VC\
set DevEnvDir=%VSInstallDir%Common7\IDE\
set Platform=X64
rem
set PATH=%VCInstallDir%bin\amd64;%VSInstallDir%VSTSDB\Deploy;%DevEnvDir%;%VCInstallDir%bin;%VSInstallDir%Common7\Tools;%FrameworkDir%%FrameworkVersion%;%FrameworkDir%%Framework35Version%;%VCInstallDir%VCPackages;%VSInstallDir%Team Tools\Performance Tools\x64;%VSInstallDir%Team Tools\Performance Tools;%WindowsSdkDir%bin\NETFX 4.0 Tools\x64;%WindowsSdkDir%bin\x64;%WindowsSdkDir%bin;%PATH%
set LIB=%LIB%;%WindowsSdkDir%lib\x64;%VCInstallDir%lib\amd64;%VCInstallDir%atlmfc\lib\amd64
set LIBPATH=%FrameworkDir%%FrameworkVersion%;%FrameworkDir%%Framework35Version%;%VCInstallDir%lib\amd64;%VCInstallDir%atlmfc\lib\amd64
set INCLUDE=%INCLUDE%;%WindowsSdkDir%include;%VCInstallDir%include;%VCInstallDir%atlmfc\include
REM
%REG32% ADD "HKLM\Software\Microsoft\VisualStudio\%VCVersion%" /v "Source Directories" /d "%VCInstallDir%crt\src\;%VCInstallDir%atlmfc\src\mfc\;%VCInstallDir%atlmfc\src\mfcm\;%VCInstallDir%atlmfc\src\atl\;%VCInstallDir%atlmfc\include\\" /f
if "%force%"=="yes" goto force_vc10x64
cmp -s "%VCSettings%Microsoft.Cpp.x64.user_Alan_vc10.props" "%VCSettings%Microsoft.Cpp.x64.user.props"
if %ERRORLEVEL% EQU 0 goto done
:force_vc10x64
cp "%VCSettings%Microsoft.Cpp.x64.user_Alan_vc10.props" "%VCSettings%Microsoft.Cpp.x64.user.props"
if not "%silent%"=="yes" echo Environment varibles set for %VCName%, target x64.
goto done
rem --------------------------------------------------------------------------
:vc106x64
REM
REM Set the build environment for VC10 DevEnv.exe and msbuild.exe, but
REM target backward-compatible 64-bit x64 (W2K3 x64 and XP x64).
REM
REM Uses the March 2006 Platform SDK cross-compiler 
REM H:\MSSDK06\bin\win64\x86\AMD64\cl.exe (version 14.00.40310) with
REM the VC6 includes and MSSDK06 libs.
REM
REM The VC6 includes are updated for 32/64-bit in \DDK\7100\.
REM We use H:\MSSDK10 includes because they still work.  When a newer SDK fails
REM fall back to \DDK\7100 includes (might need work).
REM
set VCSettings=%VC10Settings%
set HomeVCSettings=%HomeVC10Settings%
set VCName=VS2010
set VCVersion=10.0
set VCLib=
set Framework35Version=v3.5
set FrameworkSDKDir=
set FrameworkVersion=v4.0.30319
set FrameworkVersion32=
set FrameworkVersion64=v4.0.30319
set FrameworkDir=%SystemRoot%\Microsoft.NET\Framework\
set FrameworkDir32=%SystemRoot%\Microsoft.NET\Framework\
set FrameworkDir64=
set WindowsSdkDir06=H:\MSSDK06\
rem We want to use \MSSDK10 to pick up Vista/Win7 Includes.
set WindowsSdkDir=H:\MSSDK10\
set VSInstallDir=H:\%VCName%\
set VCInstallDir=%VSInstallDir%VC\
set DevEnvDir=%VSInstallDir%Common7\IDE\
set Platform=X64
set PATH=%WindowsSdkDir06%bin;%WindowsSdkDir06%bin\win64\x86\AMD64;%VCInstallDir%bin;%VSInstallDir%Common7\Tools;%DevEnvDir%;%VCInstallDir%vcpackages;%FrameworkDir%%FrameworkVersion%;%FrameworkDir%%Framework35Version%;%PATH%
REM BUG: MSSDK06 does not have a native x64 compiler. MSBuild4 requires
REM that all tools be consistently 32-bit or consistently 64-bit.
REM if not "%ProgramFiles(x86)%"=="" set PATH=%WindowsSdkDir%bin\X64;%PATH%
rem Cannot use the VS2010 x64 compiler because it generates unref symbols.
rem set PATH=%WindowsSdkDir%bin;%FrameworkDir%%FrameworkVersion%;%FrameworkDir%%Framework35Version%;%VCInstallDir%bin\amd64;%VCInstallDir%bin;%VSInstallDir%Common7\Tools;%VSInstallDir%Common7\IDE;%VCInstallDir%vcpackages;%PATH%
rem
set LIB=%WindowsSdkDir06%lib\amd64;%;%WindowsSdkDir06%lib\amd64\atlmfc
rem Cannot use the following - missing H:\DDK\7100\bin\amd64\msvcrtd.dll
rem set LIB=%LIB%;%VCLib%;%WindowsSdkDir%lib;%FrameworkSDKDir%lib;H:\DDK\7100\lib\crt\amd64;H:\DDK\7100\lib\atl\amd64;H:\DDK\7100\lib\mfc\amd64
set LIBPATH=%FrameworkDir%%FrameworkVersion%;%FrameworkDir%%Framework35Version%
set INCLUDE=%WindowsSdkDir%include;%WindowsSdkDir06%include\mfc;%WindowsSdkDir06%include\atl;%WindowsSdkDir06%include\crt;%INCLUDE%
rem Cannot use the following
rem set INCLUDE=E:\ae\atl30;%WindowsSdkDir%include;H:\DDK\7100\inc\crt;H:\DDK\7100\inc\mfc42;H:\DDK\7100\inc\api\crt\stl60;%INCLUDE%
REM
%REG32% ADD "HKLM\Software\Microsoft\VisualStudio\%VCVersion%" /v "Source Directories" /d "%WindowsSdkDir06%src\crt\;%WindowsSdkDir06%src\mfc\;%WindowsSdkDir06%include\crt\;%WindowsSdkDir06%include\mfc\;%WindowsSdkDir06%include\atl\\" /f
if "%force%"=="yes" goto force_vc106x64
cmp -s "%VCSettings%Microsoft.Cpp.x64.user_Alan_vc106.props" "%VCSettings%Microsoft.Cpp.x64.user.props"
if %ERRORLEVEL% EQU 0 goto done
:force_vc106x64
cp "%VCSettings%Microsoft.Cpp.x64.user_Alan_vc106.props" "%VCSettings%Microsoft.Cpp.x64.user.props"
if not "%silent%"=="yes" echo Environment varibles set for %VCName%, target x64, with MSVCRT.DLL compiler and libs
goto done
rem --------------------------------------------------------------------------
:w32
set watcom=d:\watcom
set edpath=%watcom%\eddat
set path=%watcom%\bin;%watcom%\binb;%watcom%\binw;%path%
set include=%include%;%watcom%\h;%watcom%\h\win
set lib=%lib%
goto done
:w32_win32s
set watcom=d:\watcom
set edpath=%watcom%\eddat
set toolrootdir=d:\msdev
set path=%watcom%\bin;%watcom%\binb;%path%
rem set lib=%lib%;%toolrootdir%\lib;%toolrootdir%\mfc\lib
set lib=%lib%
set include=%include%;%watcom%\h;%watcom%\h\nt
goto done
:w32_nt
set watcom=d:\watcom
set edpath=%watcom%\eddat
set toolrootdir=d:\msdev
set path=%watcom%\binnt;%watcom%\bin;%watcom%\binb;%path%
set lib=%lib%;%toolrootdir%\lib;%toolrootdir%\mfc\lib
set include=%include%;%watcom%\h;%watcom%\h\nt;%toolrootdir%\h;%toolrootdir%\mfc\include
set cpu=i386
goto done
:w32_os2
set watcom=d:\watcom
set edpath=%watcom%\eddat
set path=%watcom%\bin;%watcom%\binb;h:\toolkit\os2bin;%path%
set lib=%lib%
set include=.;%watcom%\h;h:\toolkit\c\os2h
goto done
:done
set VC8Settings=
set VC9Settings=
set VC10Settings=
set VCSettings=
set HomeVC8Settings=
set HomeVC9Settings=
set HomeVC10Settings=
set HomeVCSettings=
set WindowsSdkDir06=
set VCName=
set VCVersion=
set VCLib=
set REG32=
set silent=
set force=
exit /b 0
