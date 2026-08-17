set ENV=xxx
set TARGETGDB=C:\xxx\yyy.sde
set TARGETSCHEMA=CSCL
set TARGETPASSWORD=xxx
set TARGETDB=xxxxxxx
set BASEPATH=C:\xxx
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
set PROPY=C:\Users\%USERNAME%\AppData\Local\Programs\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set BATLOG=%TARGETLOGDIR%%ENV%-cscl-teardown.log
echo starting %ENV% cscl teardown of %TARGETGDB% on %date% at %time% > %BATLOG%
echo. >> %BATLOG% && echo starting reveal_all_history in %TARGETSCHEMA% on %TARGETDB% on %date% at %time% >> %BATLOG%
%PROPY% %BASEPATH%\cscl-migrate\src\py\teardown-cscl-migrate.py %TARGETGDB% listoflists
if %ERRORLEVEL% NEQ 0 (
	echo. >> %BATLOG%
	echo failed geodatabase teardown on %TARGETGDB% >> %BATLOG%
	EXIT /B 0
)
sqlplus %TARGETSCHEMA%/"%TARGETPASSWORD%"@%TARGETDB% ^
	@src/sql/drop_sequences.sql ^
	%TARGETLOGDIR%%ENV%-drop_sequences.log
if %ERRORLEVEL% NEQ 0 (
	echo. >> %BATLOG%
	echo failed drop_sequences in %TARGETSCHEMA% on %TARGETDB% >> %BATLOG%
	EXIT /B 0
)
echo. >> %BATLOG% && echo review the logs at %TARGETLOGDIR% >> %BATLOG%
echo. >> %BATLOG% && echo completed %ENV% cscl teardown of %TARGETGDB% on %date% at %time%  >> %BATLOG%
   