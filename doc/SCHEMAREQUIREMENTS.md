# Requirements for CSCL and Associated Schemas

CSCL requires 4 defined types of schemas. The schema names under each type may vary.

1. Data Creator: CSCL
2. Developer sandbox schemas
3. Editor schemas
4. Read only schemas

What follows is based on the [ESRI documentation](https://doc.esri.com/en/arcgis-pro/latest/help/data/geodatabases/manage-oracle/privileges-oracle.html#FF9) plus a few required for custom application development.

Additional grants (like public execute on system packages) should have been performed during geodatabase setup. These are out of scope for new schemas in this project.

## 0. All schemas

No application-level encryption.

## 1. Data creator: CSCL

Size: 30 GB

Roles:

* connect
* resource

Direct grants:

* create procedure
* create sequence
* create synonym
* create table
* create trigger
* create type
* create view



## 2. Developer sandbox schemas

Identical to the CSCL data owner. 

## 3. Editor schemas

Size: 5 GB

Roles:

* connect
* resource

Direct grants:

We have been requesting these but they may be unnecessary. Re-evaluate.

* create procedure
* create sequence
* create synonym
* create table
* create trigger
* create type
* create view

## 4. Read only schemas

Size: 1 GB

Roles:

* connect
* resource

## Data owner and developer sandbox schema check

Run this SQL to verify CSCL and sandbox developer schemas.

```sql
-- we are missing privileges if anything is returned
-- when executed from the data creator 
-- https://doc.esri.com/en/arcgis-pro/latest/help/data/geodatabases/manage-oracle/privileges-oracle.html
-- we also expect some privileges to be granted directly
--   instead of through roles. This allows use in 
--   stored procedures.
select missing
from (
    (
        select regexp_substr('GRANT EXECUTE ON SYS.DBMS_PIPE TO PUBLIC,GRANT EXECUTE ON SYS.DBMS_LOCK TO PUBLIC,GRANT EXECUTE ON SYS.DBMS_LOB TO PUBLIC,GRANT EXECUTE ON SYS.DBMS_UTILITY TO PUBLIC,GRANT EXECUTE ON SYS.DBMS_SQL TO PUBLIC,GRANT EXECUTE ON SYS.UTL_RAW TO PUBLIC','[^,]+',1,level) as missing
        from dual
        connect by regexp_substr('GRANT EXECUTE ON SYS.DBMS_PIPE TO PUBLIC,GRANT EXECUTE ON SYS.DBMS_LOCK TO PUBLIC,GRANT EXECUTE ON SYS.DBMS_LOB TO PUBLIC,GRANT EXECUTE ON SYS.DBMS_UTILITY TO PUBLIC,GRANT EXECUTE ON SYS.DBMS_SQL TO PUBLIC,GRANT EXECUTE ON SYS.UTL_RAW TO PUBLIC','[^,]+',1,level) is not null
        minus
        select 'GRANT EXECUTE ON SYS.' || table_name || ' TO PUBLIC'
        from all_tab_privs
        where table_schema = 'SYS'
          and table_name in ('DBMS_LOB','DBMS_LOCK','DBMS_PIPE','DBMS_UTILITY','DBMS_SQL','UTL_RAW')
          and grantee = 'PUBLIC'
    )
    union
    (
        select regexp_substr('CREATE SESSION,CREATE VIEW','[^,]+',1,level) as missing
        from dual
        connect by regexp_substr('CREATE SESSION,CREATE VIEW','[^,]+',1,level) is not null
        minus
        (
            select privilege
            from user_sys_privs
            union
            select r.privilege
            from user_role_privs u
            join role_sys_privs r
              on u.granted_role = r.role
        )
    )
    union
    (
        select regexp_substr('CREATE SEQUENCE,CREATE PROCEDURE,CREATE TABLE,CREATE TRIGGER,CREATE TYPE','[^,]+',1,level) as missing
        from dual
        connect by regexp_substr('CREATE SEQUENCE,CREATE PROCEDURE,CREATE TABLE,CREATE TRIGGER,CREATE TYPE','[^,]+',1,level) is not null
        minus
        select privilege
        from user_sys_privs
        where privilege in ('CREATE SEQUENCE','CREATE PROCEDURE','CREATE TABLE','CREATE TRIGGER','CREATE TYPE')
    )
)
order by missing
```