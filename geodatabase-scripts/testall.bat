rem we will use a dev schema to test versions instead of mocking
rem comment SDEFILE if a schema is not handy
set SDEFILE=X:\xxx\abc.sde
set TEMP=C:\Temp
set PYTHON1=C:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set PYTHON2=C:\Users\%USERNAME%\AppData\Local\Programs\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
if exist "%PYTHON1%" (
    set PROPY=%PYTHON1%
) else if exist "%PYTHON2%" (
    set PROPY=%PYTHON2%
) 
set OLDPY1=C:\Python27\ArcGIS10.7\python.exe
set OLDPY2=C:\Python27\ArcGIS10.8\python.exe
if exist "%OLDPY1%" (
    set OLDPY=%OLDPY1%
) else if exist "%OLDPY2%" (
    set OLDPY=%OLDPY22%
) 
call %PROPY% .\src\py\test_csclelementmgr.py
rem csclelementmgr is used in py27 extract and source-target verification
call %OLDPY% .\src\py\test_csclelementmgr.py
call %PROPY% .\src\py\test_relationshipclass_manager.py 
rem py27 compatibility for relationship classes is probably not required
call %OLDPY% .\src\py\test_relationshipclass_manager.py
if not "%SDEFILE%"=="" (
   call %PROPY% .\src\py\test_version_manager.py
)

