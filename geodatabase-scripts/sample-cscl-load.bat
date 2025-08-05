set ENV=xx
set TARGETDB=xxxxxxxx
set TARGETGDB=C:\xxx\Connections\oracle19c\%ENV%\GIS-%TARGETDB%\xxxx.sde
set BASEPATH=C:\xxx
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
REM set PROPY = C:\Users\%USERNAME%\AppData\Local\Programs\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set PROPY=C:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set BATLOG=%TARGETLOGDIR%%ENV%-cscl-load.log
echo starting %ENV% cscl-load on %date% at %time% > %BATLOG%
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
echo. >> %BATLOG% && echo finished %ENV% cscl-load on %date% at %time% >> %BATLOG%