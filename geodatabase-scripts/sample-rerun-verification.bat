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
set BATLOG=%TARGETLOGDIR%%ENV%-rerun-verification.log
set VERIFY_TARGET_GDB=%TARGETGDB%
set VERIFY_SOURCE_GDB=%SRCGDB%
set VERIFYCOUNTS_MODE=listoftablelists

echo starting %ENV% rerun-verification on %date% at %time% > %BATLOG%
CALL %BASEPATH%\cscl-migrate\geodatabase-scripts\run-verification.bat
if %ERRORLEVEL% NEQ 0 (
    EXIT /B 0
)
echo. >> %BATLOG% && echo completed %ENV% rerun-verification on %date% at %time% >> %BATLOG%