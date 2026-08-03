set ENV=xxx
set TARGETSCHEMA=xxx
set TARGETPASSWORD=xxx
set TARGETDB=xxx
set BASEPATH=C:\xxx
set TARGETGDB=%BASEPATH%\Connections\oracle19c\%ENV%\CSCL-%TARGETDB%\%TARGETSCHEMA%.sde
set TARGETLOGDIR=%BASEPATH%\cscl-migrate\geodatabase-scripts\logs\
set PYTHON1=C:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set PYTHON2=C:\Users\%USERNAME%\AppData\Local\Programs\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
if exist "%PYTHON1%" (
	set PROPY=%PYTHON1%
) else if exist "%PYTHON2%" (
	set PROPY=%PYTHON2%
)
set BATLOG=%TARGETLOGDIR%%ENV%-readonly-verification.log
set VERIFY_READONLY_LIST_NAME=allreadonly

echo starting %ENV% readonly-verification on %date% at %time% > %BATLOG%
CALL %PROPY% %BASEPATH%\cscl-migrate\src\py\verifyreadonlycounts.py %TARGETGDB% --data-owner-schema %TARGETSCHEMA% --readonly-users-list %VERIFY_READONLY_LIST_NAME%
if %ERRORLEVEL% NEQ 0 (
	EXIT /B 0
)

echo. >> %BATLOG% && echo completed %ENV% readonly-verification on %date% at %time% >> %BATLOG%