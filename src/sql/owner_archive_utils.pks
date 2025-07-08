CREATE OR REPLACE PACKAGE OWNER_ARCHIVE_UTILS
AUTHID CURRENT_USER
AS

-- authid current_user
-- data owner updates self
-- only available on target

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

    PROCEDURE refresh_stats;

     PROCEDURE alter_objectid_sequence (
        p_featureclass      IN VARCHAR2
       ,p_htable_name       IN VARCHAR2
    );

    PROCEDURE update_base_ids (
        p_featureclass  IN VARCHAR2
       ,p_htable_name   IN VARCHAR2
    );


END OWNER_ARCHIVE_UTILS;
/