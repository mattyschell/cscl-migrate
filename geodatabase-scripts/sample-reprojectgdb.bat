set WORKDIR=C:\Temp\fgdb
set INGDB=%WORKDIR%\in\cscl-migrate.gdb
set OUTGDB=%WORKDIR%\out\cscl.gdb
set BASEPATH=C:\xxx
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
set PROPY=c:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set BATLOG=%TARGETLOGDIR%sample-reprojectgdb.log
REM verify input catalog
%PROPY% %BASEPATH%\cscl-migrate\src\py\verifycatalog.py listoflists %INGDB% && (
    echo. >> %BATLOG% && echo verified input %INGDB% >> %BATLOG%
) || (
    echo. >> %BATLOG% && echo failed verification of input %INGDB%  >> %BATLOG%
    GOTO :EOF
) 
REM this is the reproject tucked away here
%PROPY% %BASEPATH%\cscl-migrate\src\py\reprojectgeodatabase.py %INGDB% %OUTGDB% %WORKDIR%
REM verify output catalog
%PROPY% %BASEPATH%\cscl-migrate\src\py\verifycatalog.py listoflists %OUTGDB% && (
    echo. >> %BATLOG% && echo verified output %OUTGDB% >> %BATLOG%
) || (
    echo. >> %BATLOG% && echo failed verification of output %OUTGDB%  >> %BATLOG%
    GOTO :EOF
) 
