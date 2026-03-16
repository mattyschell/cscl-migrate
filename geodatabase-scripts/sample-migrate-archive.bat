set ENV=xxx
set SRCSCHEMA=xxx
set SRCPASSWORD=xxx
set SRCDB=xxx
set TARGETSCHEMA=%SRCSCHEMA%
set TARGETPASSWORD=%SRCPASSWORD%
set TARGETDB=xxx
set BASEPATH=C:\xxx
set SRCGDB=%BASEPATH%\Connections\oracle19c\%ENV%\CSCL-%SRCDB%\%SRCSCHEMA%.sde
set TARGETGDB=%BASEPATH%\Connections\oracle19c\%ENV%\CSCL-%TARGETDB%\%TARGETSCHEMA%.sde
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
set BATLOG=%TARGETLOGDIR%%ENV%-migrate-archive.log
rem becomes \dev-update_all_base_ids.log or \dev-register_all_archiving.log etc
set BASESQLLOG=%TARGETLOGDIR%%ENV%-

echo starting %ENV% migrate-archive on %date% at %time% > %BATLOG%

echo. >> %BATLOG% && echo starting reveal_all_history in %SRCSCHEMA% on ^
%SRCDB% on %date% at %time% >> %BATLOG%

sqlplus %SRCSCHEMA%/"%SRCPASSWORD%"@%SRCDB% ^
    @src/sql/reveal_all_history.sql

echo. >> %BATLOG% && echo finished reveal_all_history in %SRCSCHEMA% on ^
%SRCDB% on %date% at %time% >> %BATLOG%

echo. >> %BATLOG% && echo starting py27 migrate archive from ^
%SRCGDB% to %TARGETGDB% on %date% at %time% >> %BATLOG%

CALL %OLDPY% ^
    %BASEPATH%\cscl-migrate\src\py\py27-migrate-archive.py ^
    %SRCGDB% %TARGETGDB% allarchiveclass

if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG% && echo second attempt: py27 migrate archive from ^
    %SRCGDB% to %TARGETGDB% on %date% at %time% >> %BATLOG%
    REM https://github.com/mattyschell/cscl-migrate/issues/27
    %OLDPY% ^
        %BASEPATH%\cscl-migrate\src\py\py27-migrate-archive.py ^
        %SRCGDB% %TARGETGDB% allarchiveclass
    REM continue even if issues
)

echo. >> %BATLOG% && echo finished py27 migrate archive from ^
%SRCGDB% to %TARGETGDB% on %date% at %time% >> %BATLOG%

sqlplus %TARGETSCHEMA%/"%TARGETPASSWORD%"@%TARGETDB% ^
    @src/sql/update_all_base_ids.sql ^
    %BASESQLLOG%update_all_base_ids.log ^
    %BASESQLLOG%-update_all_base_ids.log

sqlplus %TARGETSCHEMA%/"%TARGETPASSWORD%"@%TARGETDB% ^
    @src/sql/register_all_archiving.sql ^
    %BASESQLLOG%register_all_archiving.log

sqlplus %SRCSCHEMA%/"%SRCPASSWORD%"@%SRCDB% ^
    @src/sql/conceal_all_history.sql

sqlplus %TARGETSCHEMA%/"%TARGETPASSWORD%"@%TARGETDB% ^
    @src/sql/conceal_all_history.sql

CALL %PROPY% ^
    %BASEPATH%\cscl-migrate\src\py\verifycatalog.py ^
    listoflists %TARGETGDB%

if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG%
    echo failed catalog verification of output %TARGETGDB% >> %BATLOG%
    EXIT /B 0
)

CALL %OLDPY% ^
    %BASEPATH%\cscl-migrate\src\py\verifycounts.py ^
    listoftablelists %TARGETGDB% %SRCGDB%

if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG% && echo failed row count verification of output ^
    %TARGETGDB% >> %BATLOG%
    EXIT /B 0
)

echo. >> %BATLOG% && echo verified catalog and counts of ^
%TARGETGDB% >> %BATLOG%

echo. >> %BATLOG% && echo completed %ENV% migrate-archive on ^
%date% at %time% >> %BATLOG%

