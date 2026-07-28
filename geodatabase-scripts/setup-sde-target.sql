@src\sql\nyc_archive_utils.pks
@src\sql\nyc_archive_utils.pkb
grant execute on nyc_archive_utils to "CSCL";

-- Grant execute to NYCSCL if the schema exists
BEGIN
  DECLARE
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_count FROM all_users WHERE username = 'NYCSCL';
    IF v_count > 0 THEN
      EXECUTE IMMEDIATE 'grant execute on nyc_archive_utils to "NYCSCL"';
    END IF;
  END;
END;
/

-- Grant execute to CSCL_WORKING if the schema exists
BEGIN
  DECLARE
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_count FROM all_users WHERE username = 'CSCL_WORKING';
    IF v_count > 0 THEN
      EXECUTE IMMEDIATE 'grant execute on nyc_archive_utils to "CSCL_WORKING"';
    END IF;
  END;
END;
/

EXIT