set ENV=xx
set INGDB=C:\xxx\cscl-migrate\dev\cscl-migrate.gdb
set TARGETGDB=C:\xxx\Connections\oracle19c\%ENV%\GIS-ditGSdv1\dot_458a.sde
set BASEPATH=C:\xxx
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
set PROPY=C:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set BATLOG=%TARGETLOGDIR%cscl-load.log
echo starting cscl load on %date% at %time% > %BATLOG%
REM verify input catalog
%PROPY% %BASEPATH%\cscl-migrate\src\py\verifycatalog.py listoflists %INGDB%  
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed verification of input %INGDB% >> %BATLOG%
    GOTO :EOF
)
echo. >> %BATLOG% && echo verified input %INGDB% >> %BATLOG%
echo. >> %BATLOG% && echo starting load to %TARGETGDB% >> %BATLOG%
%PROPY% %BASEPATH%\cscl-migrate\src\py\load-cscl-migrate.py %INGDB% %TARGETGDB%
%PROPY% %BASEPATH%\cscl-migrate\src\py\verifycatalog.py listoflists %TARGETGDB%
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed verification of output %TARGETGDB% >> %BATLOG%
    GOTO :EOF
) 
echo. >> %BATLOG% && echo verified output %TARGETGDB% >> %BATLOG% 
echo. >> %BATLOG% && echo loaded %INGDB% to %TARGETGDB% >> %BATLOG%
   