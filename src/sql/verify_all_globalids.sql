WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- run as the data owner (e.g. CSCL or cscl_working) on the target
-- WARNs if any registered base table/featureclass has an edited row 
-- with a GLOBALID that is not present in its archive (_H) table

SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 200
SET PAGESIZE 100
DEFINE outfile = '&1'
SPOOL &outfile
call owner_archive_utils.verify_globalids();
SPOOL OFF
EXIT
