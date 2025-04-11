set BASEPATH=X:\XXX
REM set SDEFILE=%BASEPATH%\xxx\xxx\cscl.sde
set SDEFILE=C:\Temp\cscl-migrate\dev\cscl-migrate.gdb
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
set PROPY=c:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
CALL %PROPY% %BASEPATH%\cscl-migrate\src\py\verifycatalog.py listoflists