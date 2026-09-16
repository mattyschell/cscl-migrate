WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- https://github.com/mattyschell/cscl-migrate/issues/40
-- run as the data owner (e.g. CSCL or cscl_working) on the target
-- fails (non-zero exit) if any registered base table/featureclass has
-- a GLOBALID that is not present in its archive (_H) table

SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 200
SET PAGESIZE 100
DEFINE outfile = '&1'
SPOOL &outfile
call owner_archive_utils.verify_globalids();
SPOOL OFF
EXIT
