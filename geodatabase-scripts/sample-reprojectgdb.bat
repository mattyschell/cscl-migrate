set ENV=xxx
set WORKDIR=C:\Temp\fgdb
set INGDB=%WORKDIR%\in\cscl-migrate.gdb
set OUTGDB=%WORKDIR%\out\cscl.gdb
set BASEPATH=C:\xxx
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
set PROPY=c:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set BATLOG=%TARGETLOGDIR%%ENV%-reprojectgdb.log
set OUTSRID=2263
echo starting %ENV% reprojectgdb on %date% at %time% > %BATLOG%
REM verify input catalog
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
REM verify output catalog we expect topology to be missing 
%PROPY% %BASEPATH%\cscl-migrate\src\py\verifycatalog.py listoflists %OUTGDB% && (
    echo. >> %BATLOG% && echo verified output %OUTGDB% >> %BATLOG%
) || (
    echo. >> %BATLOG% && echo failed verification of output %OUTGDB%  >> %BATLOG%
) 
echo. >> %BATLOG% && echo reprojected %INGDB% to %OUTGDB% >> %BATLOG%
echo. >> %BATLOG% && echo completed %ENV% reprojectgdb on %date% at %time% >> %BATLOG%
