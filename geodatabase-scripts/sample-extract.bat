set ENV=xxx
set SRCDB=xxxxxx1
set BASEPATH=C:\xxx
rem create this folder including \env
set WORKDIR=C:\Temp\cscl-migrate\%ENV%
set INGDB=%BASEPATH%\Connections\oracle19c\%ENV%\CSCL-%SRCDB%\cscl.sde
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
set PROPY=C:\Users\%USERNAME%\AppData\Local\Programs\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set OLDPY=C:\Python27\ArcGIS10.7\python.exe
set BATLOG=%TARGETLOGDIR%%ENV%-cscl-extract.log
echo starting %ENV% cscl-extract on %date% at %time% > %BATLOG%
CALL %PROPY% %BASEPATH%\cscl-migrate\src\py\verifycatalog.py listoflists %INGDB%  
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed verification of input %INGDB% >> %BATLOG%
    GOTO :EOF
)
%PROPY% %BASEPATH%\cscl-migrate\src\py\create-cscl-migrate.py %WORKDIR%
echo. >> %BATLOG% && echo created empty cscl-migrate geodatabase >> %BATLOG%
echo. >> %BATLOG% && echo starting extraction with arcpy 2 >> %BATLOG%
CALL %OLDPY% %BASEPATH%\cscl-migrate\src\py\py27-extract-cscl-migrate.py %WORKDIR% %INGDB% listoflists
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed to extract %INGDB% >> %BATLOG%
    EXIT /B 0
) 
set VERIFY_TARGET_GDB=%WORKDIR%\cscl-migrate.gdb
set VERIFY_SOURCE_GDB=%INGDB%
set VERIFYCOUNTS_MODE=listofbasetablelists
set VERIFYCOUNTS_PY=%PROPY%
set VERIFY_LOG_LABEL=%WORKDIR%\cscl-migrate.gdb
CALL %BASEPATH%\cscl-migrate\geodatabase-scripts\run-verification.bat
if %ERRORLEVEL% NEQ 0 (
    EXIT /B 0
)
echo. >> %BATLOG% && echo extracted %INGDB% to %WORKDIR% >> %BATLOG%
echo. >> %BATLOG% && echo completed %ENV% cscl-extract on %date% at %time% >> %BATLOG%
   