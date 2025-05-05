set ENV=xxx
set TARGETGDB=C:\xxx\yyy.sde
set BASEPATH=C:\xxx
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
set PROPY=C:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set BATLOG=%TARGETLOGDIR%%ENV%-cscl-teardown.log
echo starting cscl teardown of %TARGETGDB% on %date% at %time% > %BATLOG%
%PROPY% %BASEPATH%\cscl-migrate\src\py\teardown-cscl-migrate.py %TARGETGDB%
echo. >> %BATLOG% && echo review the log at %TARGETLOGDIR% >> %BATLOG%
echo. >> %BATLOG% && echo ending cscl teardown of %TARGETGDB% >> %BATLOG%