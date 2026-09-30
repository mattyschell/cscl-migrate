WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- https://github.com/mattyschell/cscl-migrate/issues/40
-- run as the data owner (e.g. CSCL or cscl_working) on the target

SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 200
SET PAGESIZE 100
DEFINE outfile = '&1'
SPOOL &outfile
call owner_archive_utils.update_baseglobalids();
SPOOL OFF
EXIT