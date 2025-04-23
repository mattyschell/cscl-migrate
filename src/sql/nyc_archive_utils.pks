CREATE OR REPLACE PACKAGE NYC_ARCHIVE_UTILS
AUTHID CURRENT_USER
AS

--   *****     *****
--  ********* *********
-- *********** **********
-- ************************
--  ***********************
--   *********************
--    *******************
--      ***************
--        ***********
--          *******
--            ***
--             *
--       P  L  /  S  Q  L

    PROCEDURE fetch_h_table (
        p_featureclass      IN VARCHAR2
       ,p_hregistration_id  OUT NUMBER
       ,p_htable_name       OUT VARCHAR2
    );


    PROCEDURE reveal_history (
        p_featureclass  IN VARCHAR2
    );

    PROCEDURE conceal_history (
        p_featureclass  IN VARCHAR2
    );

    PROCEDURE register_archiving (
        p_featureclass  IN VARCHAR2
       ,p_archive_date  IN NUMBER
    );


END NYC_ARCHIVE_UTILS;
/