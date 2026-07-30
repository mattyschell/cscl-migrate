if not defined VERIFY_TARGET_GDB (
    echo VERIFY_TARGET_GDB is required
    EXIT /B 1
)

if not defined VERIFY_SOURCE_GDB (
    echo VERIFY_SOURCE_GDB is required
    EXIT /B 1
)

if not defined VERIFYCOUNTS_MODE (
    set VERIFYCOUNTS_MODE=listofbasetablelists
)

if not defined VERIFYCATALOG_PY (
    set VERIFYCATALOG_PY=%PROPY%
)

if not defined VERIFYCOUNTS_PY (
    set VERIFYCOUNTS_PY=%OLDPY%
)

if not defined VERIFY_CATALOG_FAIL_LEVEL (
    set VERIFY_CATALOG_FAIL_LEVEL=1
)

if not defined VERIFY_LOG_LABEL (
    set VERIFY_LOG_LABEL=%VERIFY_TARGET_GDB%
)

if not defined VERIFY_RUN_AS_READONLY_USERS (
    set VERIFY_RUN_AS_READONLY_USERS=0
)

CALL :RUN_VERIFICATION "%VERIFY_TARGET_GDB%" "%VERIFY_LOG_LABEL%" "0" "0"
if ERRORLEVEL 1 (
    EXIT /B 1
)

if /i "%VERIFY_RUN_AS_READONLY_USERS%"=="1" if /i "%TARGETSCHEMA%"=="CSCL" (
    CALL :RUN_READONLY_VERIFICATIONS
    EXIT /B %ERRORLEVEL%
)

EXIT /B 0

:RUN_READONLY_VERIFICATIONS
    if not defined VERIFY_READONLY_LIST_NAME (
        set VERIFY_READONLY_LIST_NAME=allreadonly
    )

    if not exist "%BASEPATH%\cscl-migrate\src\py\resources\%VERIFY_READONLY_LIST_NAME%" (
        echo VERIFY_READONLY_USERS_FILE not found: %BASEPATH%\cscl-migrate\src\py\resources\%VERIFY_READONLY_LIST_NAME%
        EXIT /B 1
    )

    set VERIFY_READONLY_ANY=
    set VERIFY_READONLY_FAILED=
    for /f "usebackq tokens=* delims=" %%U in ("%BASEPATH%\cscl-migrate\src\py\resources\%VERIFY_READONLY_LIST_NAME%") do (
        set VERIFY_READONLY_ANY=1
        echo.
        echo verifying read-only user %%U
        if defined BATLOG (
            echo. >> %BATLOG%
            echo verifying read-only user %%U >> %BATLOG%
        )
        for %%I in ("%VERIFY_TARGET_GDB%") do CALL :RUN_VERIFICATION "%%~dpI%%U.sde" "%%U" "1" "1"
        if ERRORLEVEL 1 (
            set VERIFY_READONLY_FAILED=Y
        )
    )

    if not defined VERIFY_READONLY_ANY (
        echo no users found in %BASEPATH%\cscl-migrate\src\py\resources\%VERIFY_READONLY_LIST_NAME%
        EXIT /B 1
    )

    if defined VERIFY_READONLY_FAILED (
        echo.
        echo one or more read-only users failed verification
        if defined BATLOG (
            echo one or more read-only users failed verification >> %BATLOG%
        )
        EXIT /B 1
    )

    if defined BATLOG (
        echo. >> %BATLOG%
        echo verified read-only access for all users in list %VERIFY_READONLY_LIST_NAME% >> %BATLOG%
    )

    EXIT /B 0

:RUN_VERIFICATION
set VERIFY_TARGET_GDB_CURRENT=%~1
set VERIFY_LOG_LABEL_CURRENT=%~2
set VERIFY_SKIP_COUNTS=%~3
set VERIFY_SKIP_CATALOG=%~4

if "%VERIFY_SKIP_CATALOG%"=="1" goto AFTER_CATALOG

CALL %VERIFYCATALOG_PY% %BASEPATH%\cscl-migrate\src\py\verifycatalog.py listoflists %VERIFY_TARGET_GDB_CURRENT%

if ERRORLEVEL %VERIFY_CATALOG_FAIL_LEVEL% (
    echo.
    echo failed catalog verification of output %VERIFY_TARGET_GDB_CURRENT%
    if defined BATLOG (
        echo. >> %BATLOG%
        echo failed catalog verification of output %VERIFY_TARGET_GDB_CURRENT% >> %BATLOG%
    )
    EXIT /B 1
)

:AFTER_CATALOG

if /i "%TARGETSCHEMA%"=="CSCL" (
    if "%VERIFY_SKIP_COUNTS%"=="1" (
        CALL %VERIFYCATALOG_PY% %BASEPATH%\cscl-migrate\src\py\verifydomain.py alldomain %VERIFY_TARGET_GDB% %TARGETSCHEMA% %VERIFY_LOG_LABEL_CURRENT%
    ) else (
        CALL %VERIFYCATALOG_PY% %BASEPATH%\cscl-migrate\src\py\verifydomain.py alldomain %VERIFY_TARGET_GDB_CURRENT% %TARGETSCHEMA%
    )
    
    if ERRORLEVEL 1 (
        echo.
        echo failed domain verification of output %VERIFY_TARGET_GDB_CURRENT%
        if defined BATLOG (
            echo. >> %BATLOG%
            echo failed domain verification of output %VERIFY_TARGET_GDB_CURRENT% >> %BATLOG%
        )
        EXIT /B 1
    )
)

if "%VERIFY_SKIP_COUNTS%"=="1" (
    if defined BATLOG (
        echo. >> %BATLOG%
        if "%VERIFY_SKIP_CATALOG%"=="1" (
            echo skipped catalog and source-target count verification of %VERIFY_LOG_LABEL_CURRENT% >> %BATLOG%
        ) else (
            echo verified catalog access of %VERIFY_LOG_LABEL_CURRENT% >> %BATLOG%
        )
    )
    EXIT /B 0
)

CALL %VERIFYCOUNTS_PY% %BASEPATH%\cscl-migrate\src\py\verifycounts.py %VERIFYCOUNTS_MODE% %VERIFY_TARGET_GDB_CURRENT% %VERIFY_SOURCE_GDB%

if ERRORLEVEL 1 (
    echo.
    echo failed row count verification of output %VERIFY_TARGET_GDB_CURRENT%
    if defined BATLOG (
        echo. >> %BATLOG%
        echo failed row count verification of output %VERIFY_TARGET_GDB_CURRENT% >> %BATLOG%
    )
    EXIT /B 1
)

if defined BATLOG (
    echo. >> %BATLOG%
    echo verified catalog and counts of %VERIFY_LOG_LABEL_CURRENT% >> %BATLOG%
)

EXIT /B 0