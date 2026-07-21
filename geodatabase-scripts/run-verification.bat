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

CALL %VERIFYCATALOG_PY% %BASEPATH%\cscl-migrate\src\py\verifycatalog.py listoflists %VERIFY_TARGET_GDB%

if ERRORLEVEL %VERIFY_CATALOG_FAIL_LEVEL% (
    echo.
    echo failed catalog verification of output %VERIFY_TARGET_GDB%
    if defined BATLOG (
        echo. >> %BATLOG%
        echo failed catalog verification of output %VERIFY_TARGET_GDB% >> %BATLOG%
    )
    EXIT /B 1
)

CALL %VERIFYCOUNTS_PY% %BASEPATH%\cscl-migrate\src\py\verifycounts.py %VERIFYCOUNTS_MODE% %VERIFY_TARGET_GDB% %VERIFY_SOURCE_GDB%

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo failed row count verification of output %VERIFY_TARGET_GDB%
    if defined BATLOG (
        echo. >> %BATLOG%
        echo failed row count verification of output %VERIFY_TARGET_GDB% >> %BATLOG%
    )
    EXIT /B 1
)

if defined BATLOG (
    echo. >> %BATLOG%
    echo verified catalog and counts of %VERIFY_LOG_LABEL% >> %BATLOG%
)

EXIT /B 0