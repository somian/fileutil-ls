@echo off
setlocal
REM
REM BUILD.CMD - Build and install msls
REM
REM $Id: BUILD.CMD,v 1.8 2010/05/14 02:34:55 cvsalan Exp $
REM
choice /C DR /N /M "[D]ebug or [R]elease? "
if errorlevel 2 set BLDTYPE=Release
if errorlevel 1 set BLDTYPE=Debug
call SETBUILD.CMD vc6
nmake /nologo clean CFG="msls - Win32 %BLDTYPE%"
if errorlevel 1 goto done
if "%BLDTYPE%"=="Release" C:\Python32\python.exe BumpVersion.py
nmake /nologo CFG="msls - Win32 %BLDTYPE%" 
if errorlevel 1 goto done
cd dircolors
nmake /nologo CFG="dircolors - Win32 %BLDTYPE%" 
if errorlevel 1 ( cd .. & goto done )
cd ..
if "%BLDTYPE%"=="Release" goto release
goto done
:release
rem 
rem Install into final location.  This path will vary depending
rem on your folder layout.
rem
copy /Y Release\ls.exe c:\lbin\ls.exe
copy /Y Release\ls.exe c:\vmshared\ls.exe
copy /Y dircolors\Release\dircolors.exe c:\lbin\dircolors.exe
rem
copy /Y DOC\msls.htm c:\inetpub\wwwroot\utools\msls.htm
copy /Y DOC\msls.css c:\inetpub\wwwroot\utools\msls.css
rem
rem
choice /C YN /M "Build Distribution "
if errorlevel 2 goto done
rem
rem The remainder of this file is for packaging the distribution
rem and is not likely to be helpful to you
rem
set URL="http://utools.com/msls.asp"
rem
rem Sign the .EXE with Authenticode Certificate
rem
signcode -spc c:\certcode11.spc -v c:\certcode11.pvk -n "ls for Windows" -a sha1 -i %URL% -t "http://timestamp.verisign.com/scripts/timestamp.dll" Release\ls.exe
if errorlevel 1 goto done
copy /Y Release\ls.exe c:\lbin\ls.exe
rem
rem Make DISTRIB for distribution
rem
rm -rf DISTRIB_EXE
mkdir DISTRIB_EXE
copy Release\ls.exe DISTRIB_EXE
copy dircolors\Release\dircolors.exe DISTRIB_EXE
copy README.TXT DISTRIB_EXE
copy COPYING DISTRIB_EXE
copy DOC\* DISTRIB_EXE
copy C:\lbin\grep.exe DISTRIB_EXE
rem
rem Make DISTRIB_SRC for distribution
rem
rm -rf DISTRIB_SRC
mkdir DISTRIB_SRC
copy README.TXT DISTRIB_SRC\README.TXT
copy COPYING DISTRIB_SRC\COPYING
copy *.h DISTRIB_SRC
copy *.c DISTRIB_SRC
copy *.cpp DISTRIB_SRC
copy *.cmd DISTRIB_SRC
copy *.rc DISTRIB_SRC
copy *.manifest DISTRIB_SRC
copy Makefile DISTRIB_SRC\Makefile
mkdir DISTRIB_SRC\dircolors
copy dircolors\*.h?? DISTRIB_SRC\dircolors
copy dircolors\*.c DISTRIB_SRC\dircolors
copy dircolors\Makefile DISTRIB_SRC\dircolors\Makefile
rem
rem Build zip packages
rem
rm -rf DISTRIB_ZIP
mkdir DISTRIB_ZIP
cd DISTRIB_EXE
zip.exe -9 -v -o -r ..\DISTRIB_ZIP\msls.zip *
cd ..\DISTRIB_SRC
zip.exe -9 -v -o -r ..\DISTRIB_ZIP\msls_src.zip *
cd ..\DISTRIB_ZIP
if NOT "%ProgramFiles(x86)%"=="" goto 64bit
set WZIPSE="%ProgramFiles%\wzipse\winzipse.exe"
goto cont
:64bit
set WZIPSE="%ProgramFiles(x86)%\wzipse\winzipse.exe"
:cont
%WZIPSE% msls.zip @..\winzipse.inp
rem
rem Sign the self-extracting .EXE with Authenticode Certificate
rem
signcode -spc c:\certcode11.spc -v c:\certcode11.pvk -n "ls for Windows" -a sha1 -i %URL% -t "http://timestamp.verisign.com/scripts/timestamp.dll" msls.exe
if errorlevel 1 goto done
cd ..
echo Build complete in DISTRIB_ZIP.
:done
endlocal
