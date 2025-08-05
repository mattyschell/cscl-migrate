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
set PROPY=C:\Users\%USERNAME%\AppData\Local\Programs\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set OLDPY=C:\Python27\ArcGIS10.7\python.exe
set BATLOG=%TARGETLOGDIR%%ENV%-migrate-archive.log
set BASESQLLOG=%TARGETLOGDIR%%ENV%-
echo starting %ENV% migrate-archive on %date% at %time% > %BATLOG%
echo. >> %BATLOG% && echo starting reveal_all_history in %SRCSCHEMA% on %SRCDB% on %date% at %time% >> %BATLOG%
sqlplus %SRCSCHEMA%/"%SRCPASSWORD%"@%SRCDB% @src/sql/reveal_all_history.sql
echo. >> %BATLOG% && echo finished reveal_all_history in %SRCSCHEMA% on %SRCDB% on %date% at %time% >> %BATLOG%
echo. >> %BATLOG% && echo starting py27 migrate archive from %SRCGDB% to %TARGETGDB% on %date% at %time% >> %BATLOG%
%OLDPY% %BASEPATH%\cscl-migrate\src\py\py27-migrate-archive.py %SRCGDB% %TARGETGDB% allarchiveclass
if %ERRORLEVEL% NEQ 0 (
    echo. >> %BATLOG% && echo second attempt: py27 migrate archive from %SRCGDB% to %TARGETGDB% on %date% at %time% >> %BATLOG%
    REM https://github.com/mattyschell/cscl-migrate/issues/27
    %OLDPY% %BASEPATH%\cscl-migrate\src\py\py27-migrate-archive.py %SRCGDB% %TARGETGDB% allarchiveclass
    REM continue even if issues
) 
echo. >> %BATLOG% && echo finished py27 migrate archive from %SRCGDB% to %TARGETGDB% on %date% at %time% >> %BATLOG%
sqlplus %TARGETSCHEMA%/"%TARGETPASSWORD%"@%TARGETDB% @src/sql/update_all_base_ids.sql %BASESQLLOG%update_all_base_ids.log %BASESQLLOG%-update_all_base_ids.log
sqlplus %TARGETSCHEMA%/"%TARGETPASSWORD%"@%TARGETDB% @src/sql/%ENV%_register_all_archiving.sql %BASESQLLOG%register_all_archiving.log
sqlplus %SRCSCHEMA%/"%SRCPASSWORD%"@%SRCDB% @src/sql/conceal_all_history.sql
sqlplus %TARGETSCHEMA%/"%TARGETPASSWORD%"@%TARGETDB% @src/sql/conceal_all_history.sql
echo. >> %BATLOG% && echo completed %ENV% migrate-archive on %date% at %time% >> %BATLOG%

