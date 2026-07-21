set ENV=xxx
set WORKDIR=C:\Temp\cscl-migrate\%ENV%
set INGDB=%WORKDIR%\cscl-migrate.gdb
set OUTGDB=%WORKDIR%\cscl-migrate-reproj.gdb
set BASEPATH=C:\xxx
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
set PROPY=c:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set BATLOG=%TARGETLOGDIR%%ENV%-reprojectgdb.log
set OUTSRID=2263
echo starting %ENV% reprojectgdb on %date% at %time% > %BATLOG%
%PROPY% %BASEPATH%\cscl-migrate\src\py\verifycatalog.py listoflists %INGDB% && (
    echo. >> %BATLOG% && echo verified input %INGDB% >> %BATLOG%
) || (
    echo. >> %BATLOG% && echo failed verification of input %INGDB%  >> %BATLOG%
    GOTO :EOF
) 
REM this is the so called reproject 
%PROPY% %BASEPATH%\cscl-migrate\src\py\reprojectgeodatabase.py %INGDB% %OUTGDB% %WORKDIR% %OUTSRID%
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed reprojectgeodatabase review the log >> %BATLOG%
    GOTO :EOF
)
set VERIFY_TARGET_GDB=%OUTGDB%
set VERIFY_SOURCE_GDB=%INGDB%
set VERIFYCOUNTS_MODE=listofbasetablelists
set VERIFYCOUNTS_PY=%PROPY%
set VERIFY_CATALOG_FAIL_LEVEL=2
CALL %BASEPATH%\cscl-migrate\geodatabase-scripts\run-verification.bat
if %ERRORLEVEL% NEQ 0 (
    EXIT /B 0
)
echo. >> %BATLOG% && echo reprojected %INGDB% to %OUTGDB% >> %BATLOG%
echo. >> %BATLOG% && echo completed %ENV% reprojectgdb on %date% at %time% >> %BATLOG%