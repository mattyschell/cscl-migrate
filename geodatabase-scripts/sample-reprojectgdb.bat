set WORKDIR=C:\Temp\fgdb
set INGDB=%WORKDIR%\in\cscl-migrate.gdb
set OUTGDB=%WORKDIR%\out\cscl.gdb
set BASEPATH=C:\xxx
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
set PROPY=c:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set BATLOG=%TARGETLOGDIR%sample-reprojectgdb.log
%PROPY% %BASEPATH%\cscl-migrate\src\py\reprojectgeodatabase.py %INGDB% %OUTGDB% %WORKDIR%
