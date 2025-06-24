set ENV=xx
set TARGETGDB=C:\xxx\Connections\oracle19c\%ENV%\GIS-ditGSdv1\xxxx.sde
set BASEPATH=C:\xxx
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
set PROPY=C:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set BATLOG=%TARGETLOGDIR%%ENV%-cscl-load.log
echo. >> %BATLOG% && echo finalizing load to %TARGETGDB% >> %BATLOG%
%PROPY% %BASEPATH%\cscl-migrate\src\py\loadcscl.py %TARGETGDB%
if %ERRORLEVEL% NEQ 0 (
   echo. >> %BATLOG%
   echo failed load of %INGDB% to %TARGETGDB% >> %BATLOG%
   GOTO :EOF
)
%PROPY% %BASEPATH%\cscl-migrate\src\py\verifycatalog.py listoflists %TARGETGDB% 
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed verification of output %TARGETGDB% >> %BATLOG%
    GOTO :EOF
) 
echo. >> %BATLOG% && echo verified output %TARGETGDB% >> %BATLOG% 
echo. >> %BATLOG% && echo finalized CSCL in %TARGETGDB% >> %BATLOG%