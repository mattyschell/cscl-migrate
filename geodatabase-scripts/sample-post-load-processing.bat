set ENV=xx
set TARGETDB=xxxxxxxx
set BASEPATH=C:\xxx
set TARGETGDB=%BASEPATH%\Connections\oracle19c\%ENV%\GIS-%TARGETDB%\xxxx.sde
set SRCGDB=%BASEPATH%\Connections\oracle19c\%ENV%\xxxx\xxx.sde
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
set PYTHON1=C:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set PYTHON2=C:\Users\%USERNAME%\AppData\Local\Programs\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
if exist "%PYTHON1%" (
    set PROPY=%PYTHON1%
) else if exist "%PYTHON2%" (
    set PROPY=%PYTHON2%
) 
set PYTHON107=C:\Python27\ArcGIS10.7\python.exe
set PYTHON108=C:\Python27\ArcGIS10.8\python.exe
if exist "%PYTHON107%" (
    set OLDPY=%PYTHON107%
) else if exist "%PYTHON108%" (
    set OLDPY=%PYTHON108%
)
set BATLOG=%TARGETLOGDIR%%ENV%-cscl-load.log
echo starting %ENV% cscl-load on %date% at %time% > %BATLOG%
CALL %PROPY% %BASEPATH%\cscl-migrate\src\py\finalizeloadcscl.py %TARGETGDB%
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed finalizeload of %INGDB% to %TARGETGDB% >> %BATLOG%
    EXIT /B 0
)
echo. >> %BATLOG% && echo finalized load to %TARGETGDB% >> %BATLOG%
CALL %PROPY% %BASEPATH%\cscl-migrate\src\py\applygrants.py %TARGETGDB%
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed applygrants on %TARGETGDB% >> %BATLOG%
    EXIT /B 0
)
CALL %PROPY% %BASEPATH%\cscl-migrate\src\py\createversions.py %TARGETGDB%
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed createversions on %TARGETGDB% >> %BATLOG%
    EXIT /B 0
)
CALL %PROPY% %BASEPATH%\cscl-migrate\src\py\verifycatalog.py listoflists %TARGETGDB% 
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed catalog verification of output %TARGETGDB% >> %BATLOG%
    EXIT /B 0
) 
rem use py27 with class extensions to get source counts
CALL %OLDPY% %BASEPATH%\cscl-migrate\src\py\verifycounts.py listofbasetablelists %TARGETGDB% %SRCGDB%
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG% && echo failed row count verification of output %TARGETGDB% >> %BATLOG% 
    EXIT /B 0
) 
echo. >> %BATLOG% && echo verified catalog and counts of %TARGETGDB% >> %BATLOG% 
echo. >> %BATLOG% && echo finished %ENV% cscl-load on %date% at %time% >> %BATLOG%
EXIT /B 0
