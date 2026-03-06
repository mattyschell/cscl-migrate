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
call %PROPY% .\src\py\testcsclelementmgr.py
rem csclelementmgr is used in py27 extract
call %OLDPY% .\src\py\testcsclelementmgr.py
call %PROPY% .\src\py\test_relationshipclass_manager.py 

