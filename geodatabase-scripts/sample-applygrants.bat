rem this is a standalone caller to the scripted grants process
rem it is additive only. for adding new users or feature classes/tables
set ENV=xxx
set TARGETDB=xxxXXxxx
set BASEPATH=X:\xxx
set TARGETGDB=%BASEPATH%\Connections\oracle19c\%ENV%\CSCL-%TARGETDB%\cscl.sde
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
set PYTHON1=C:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set PYTHON2=C:\Users\%USERNAME%\AppData\Local\Programs\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
if exist "%PYTHON1%" (
    set PROPY=%PYTHON1%
) else if exist "%PYTHON2%" (
    set PROPY=%PYTHON2%
) 
set BATLOG=%TARGETLOGDIR%%ENV%-applygrants.log
echo starting %ENV% applygrants on %date% at %time% > %BATLOG%
CALL %PROPY% %BASEPATH%\cscl-migrate\src\py\applygrants.py %TARGETGDB%
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed rerungrants on %TARGETGDB% >> %BATLOG%
    EXIT /B 0
)