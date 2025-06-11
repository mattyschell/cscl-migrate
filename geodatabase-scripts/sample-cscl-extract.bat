set ENV=xxx
set SRCDB=xxxxxx1
set BASEPATH=C:\xxx
set WORKDIR=C:\Temp\cscl-migrate\%ENV%
set INGDB=%BASEPATH%\Connections\oracle19c\%ENV%\CSCL-%SRCDB%\cscl.sde
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
set PROPY=C:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set OLDPY=C:\Python27\ArcGIS10.7\python.exe
set BATLOG=%TARGETLOGDIR%cscl-extract.log
echo starting cscl-extract on %date% at %time% > %BATLOG%
REM verify input catalog
%PROPY% %BASEPATH%\cscl-migrate\src\py\verifycatalog.py listoflists %INGDB%  
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed verification of input %INGDB% >> %BATLOG%
    GOTO :EOF
)
%PROPY% %BASEPATH%\cscl-migrate\src\py\create-cscl-migrate.py %WORKDIR%
echo. >> %BATLOG% && echo created empty cscl-migrate geodatabase >> %BATLOG%
echo. >> %BATLOG% && echo starting extraction with arcpy 2 >> %BATLOG%
%OLDPY% %BASEPATH%\cscl-migrate\src\py\py27-extract-cscl-migrate.py %WORKDIR% %INGDB% listoflists
%PROPY% %BASEPATH%\cscl-migrate\src\py\verifycatalog.py listoflists %WORKDIR%\cscl-migrate.gdb
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed verification of output %WORKDIR%\cscl-migrate.gdb >> %BATLOG%
    GOTO :EOF
) 
echo. >> %BATLOG% && echo verified output %WORKDIR%\cscl-migrate.gdb >> %BATLOG% 
echo. >> %BATLOG% && %~n0 extracted %INGDB% to %WORKDIR% >> %BATLOG%
 