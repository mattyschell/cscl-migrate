set ENV=xx
set TARGETDB=xxxxxxxx
set BASEPATH=C:\xxx
set TARGETGDB=%BASEPATH%\Connections\oracle19c\%ENV%\GIS-%TARGETDB%\xxxx.sde
set SRCGDB=%BASEPATH%\Connections\oracle19c\%ENV%\xxxx\xxx.sde
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
set PROPY=C:\Users\%USERNAME%\AppData\Local\Programs\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set BATLOG=%TARGETLOGDIR%%ENV%-cscl-load.log
echo starting %ENV% cscl-load on %date% at %time% > %BATLOG%
CALL %PROPY% %BASEPATH%\cscl-migrate\src\py\finalizeloadcscl.py %TARGETGDB%
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed finalizeload of %INGDB% to %TARGETGDB% >> %BATLOG%
    EXIT /B 0
)
echo. >> %BATLOG% && echo finalized load to %TARGETGDB% >> %BATLOG%
CALL %PROPY% %BASEPATH%\cscl-migrate\src\py\verifycatalog.py listoflists %TARGETGDB% 
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed catalog verification of output %TARGETGDB% >> %BATLOG%
    EXIT /B 0
) 
CALL %PROPY% %BASEPATH%\cscl-migrate\src\py\verifycounts.py listofbasetablelists %TARGETGDB% %SRCGDB%
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG% && echo failed row count verification of output %TARGETGDB% >> %BATLOG% 
    EXIT /B 0
) 
echo. >> %BATLOG% && echo verified catalog and counts of %TARGETGDB% >> %BATLOG% 
echo. >> %BATLOG% && echo finished %ENV% cscl-load on %date% at %time% >> %BATLOG%
EXIT /B 0
