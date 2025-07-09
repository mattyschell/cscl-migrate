CREATE OR REPLACE PACKAGE NYC_ARCHIVE_UTILS
AUTHID DEFINER
AS

-- authid definer
-- data owner calls in to SDE, SDE updates self
-- this package is the only permitted updates to SDE data
-- must be compiled and available on both source and target

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
       ,p_htable_name   IN VARCHAR2
       ,p_archive_date  IN NUMBER
    );


END NYC_ARCHIVE_UTILS;
/