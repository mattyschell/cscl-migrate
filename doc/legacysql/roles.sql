-- no plans to use this
-- stashing it for historical reference
--
-- these roles are hearsay from the original CSCL application
-- GIS_ALL_USER_ROLE may have been cooked up later
-- you can see some sort of intended access control pattern  
--     by squinting at these
-- my understanding is that mostly every editor had all roles
--    applied because the implementation broke down
CREATE ROLE BASIC;
CREATE ROLE BASICPLUS;
CREATE ROLE FNSN_EDITOR;
CREATE ROLE DOITT_EDITOR;
CREATE ROLE DCP_EDITOR;
CREATE ROLE SUPERVISOR;
CREATE ROLE GIS_ALL_USER_ROLE;
grant BASIC to CSCL with admin option;
grant BASICPLUS to CSCL with admin option;
grant FNSN_EDITOR to CSCL with admin option;
grant DOITT_EDITOR to CSCL with admin option;
grant DCP_EDITOR to CSCL with admin option;
grant SUPERVISOR to CSCL with admin option;
grant GIS_ALL_USER_ROLE to CSCL with admin option;