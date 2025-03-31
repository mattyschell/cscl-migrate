## Migrating Archive Classes

These are notes from an engagement with ESRI. Unlike the goals elsewhere in this repo, for this engagement we wish to migrate CSCL via an interim step like a file geodatabase.  In this interim step we will lose the archive.

The steps below describe our preferred archive restoration strategy. This strategy is not supported by the COTS software.

### Confirm All Datasets Have a Globalid

Objectid gets toasted on the target. Globalids will serve as a persistent unique identifier.

```sql
select 
    distinct table_name 
from 
    user_tab_columns
where 
    not REGEXP_LIKE(table_name, '^[DFS][0-9]+$')
    and table_name not like 'KEYSET%'
    and table_name not like 'SDE%'
    and table_name not like 'T_1%'
minus
select 
    table_name 
from 
    user_tab_columns 
where 
    column_name = 'GLOBALID';
```

### Approach 1: Recreate


1.	Copy the feature class to a target schema. It will be registered with the geodatabase but not registered as versioned, not archiving.

In the real workflow the data will move to an interim file geodatabase here.

2.	Source: Stop archiving in source schema to excrete the _H table. You will need an exclusive lock for this.

3.	Copy the _H table to target schema and paste-very-special to rename to _H_BAK

4.	Target: objectid update

    The row count in the base table will be different than _H_BAK. The goal here is to update altered objectids in the _H_BAK table to match the base table objectids. Unmatched objectids will exist in _H_BAK this is OK they are history. (TODO: confirm this bold statement and also investigate if this has any consequences)

    In a real migration there should be no A and D versioning tables in the target schema.  Verify this.

    Probably a good idea to regather any stale statistics.  Just in case.

```sql
BEGIN
    DBMS_STATS.GATHER_SCHEMA_STATS(
        ownname          => USER, 
        options          => 'GATHER STALE', 
        estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, 
        degree           => DBMS_STATS.DEFAULT_DEGREE
    );
END;
```

(TODO: Why so slow? Globalid is indexed on both sides)

```sql
update 
    xxFEATURECLASSxx_h_bak a
set
    a.objectid = (select 
                      b.objectid
                  from 
                      xxFEATURECLASSxx b
                  where
                      b.globalid = a.globalid)
where exists
    (select 
        1 
     from
        xxFEATURECLASSxx b
    where b.globalid = a.globalid);
```    
    
    See the src/py/resources directory of this repo for lists of CSCL feature classes and tables.  Consider stupid simple generating the final list of update SQLs by starting with these lists and typing out the update statement in "column mode" of a text editor. 

5. Target: Register as versioned and archiving.

6. Target: Delete all records from the new _H table  

    (TODO: confirm this since this wasn't included in the initial procedure)
    (TODO: confirm delete vs truncate. Delete fires triggers and does not reset identity sequences)

7.	Target: Insert records from _H_backup to _H 

    First verify that we didn't accidentally get any xxFEATURECLASSxx_H1 etc tables.  

```sql
SELECT table_name
FROM user_tables
WHERE REGEXP_LIKE(table_name, '^xxFEATURECLASSxx_H[0-9]+$')
```

    The columns should be identical in name and data type but the order will change.

    (TODO: figure out the listagg or comma trimming to make this work)

```sql
select 
    'insert into xxFEATURECLASSxx_h (' 
from dual
union all
select 
    column_name || ',' 
from 
    user_tab_columns where table_name ='xxFEATURECLASSxx_h'
union all
select
    ') select ' from dual
union all
select 
    column_name || ',' 
from 
    user_tab_columns where table_name ='xxFEATURECLASSxx_h'
union all
select 
    'from xxFEATURECLASSxx_h_bak;' from dual
```

8.	See what we’ve got

Gold.  We've got gold.  


### Approach 2: Registration Update


1.	Copy the feature class to a target schema. It will be registered with the geodatabase. Register as versioned.  Do not register as archiving.

In the real workflow the data will move to an interim file geodatabase here.

2.	Source: Unset IS_HISTORY to make source _H table visible

The ID in the where clause below is of the history table not the featureclass.

```sql
-- Unset IS_HISTORY
UPDATE sde.table_registry
SET    OBJECT_FLAGS = CASE
                        WHEN MOD(TRUNC(OBJECT_FLAGS / POWER(2, 20)), 2) = 1 THEN
                        OBJECT_FLAGS - POWER(2, 20)
                        ELSE OBJECT_FLAGS
                      END
WHERE  REGISTRATION_ID = <HISTORY_REGID from SDE.SDE_ARCHIVES>;
```

Commit and refresh ESRI software.


3.	Copy the _H table to target schema and paste-NOT-special. It will be named xxFEATURECLASSxx_H

4. Source: set is_history back to 1 to restore archiving

```sql
-- Set IS_HISTORY
UPDATE 
    sde.table_registry
SET 
    OBJECT_FLAGS = CASE
                       WHEN MOD(TRUNC(OBJECT_FLAGS / POWER(2, 20)), 2) = 0 
                       THEN
                          OBJECT_FLAGS + POWER(2, 20)
                       ELSE OBJECT_FLAGS
                   END
WHERE  
    REGISTRATION_ID = <HISTORY_REGID from SDE.SDE_ARCHIVES>; 
```

5. Target: objectid update 

    The row count in the base table will be different than _H. The goal here is to update altered objectids in the _H table to match the base table objectids. Unmatched objectids will exist in _H this is OK they are history. (TODO: confirm this bold statement)

    In a real migration there should be no A and D versioning tables in the target schema.  Verify this.

    Probably a good idea to regather any stale statistics.  Just in case.

```sql
BEGIN
    DBMS_STATS.GATHER_SCHEMA_STATS(
        ownname          => USER, 
        options          => 'GATHER STALE', 
        estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, 
        degree           => DBMS_STATS.DEFAULT_DEGREE
    );
END;
```

(TODO: Why so slow? Globalid is indexed on both sides)

```sql
merge into
    xxFEATURECLASSxx_h a
using 
    xxFEATURECLASSxx b
on
    (a.globalid = b.globalid)
when matched then
update
set
    a.objectid = b.objectid;
```    
    
    See the src/py/resources directory of this repo for lists of CSCL feature classes and tables.  Consider stupid simple generating the final list of update SQLs by starting with these lists and typing out the update statement in "column mode" of a text editor. 

6. Target: Manually “register” the parent as archiving and _H table is the history table as follows:

    The ARCHIVING feature class or table has to have its IS_ARCHIVING bit (bit 18 zero-based) set.    


    ```sql
    update 
        sde.table_registry
    set 
        object_flags = CASE
                           WHEN MOD(TRUNC(OBJECT_FLAGS / POWER(2, 18)), 2) = 0 
                           THEN
                              OBJECT_FLAGS + POWER(2, 18)
                           ELSE 
                              OBJECT_FLAGS
                       END
    where 
        registration_id = (select registration_id from sde.table_registry
                            where owner = 'xxOWNERxx'
                            and table_name = 'xxFEATURECLASSxx');
    ```

    The HISTORY feature class or table has to have IS_HISTORY (bit 20) set.

    TODO: Note there was a lot of back and forth on this. Final answer appeared to be just set is_history bit (20, not 21)

    ```sql
    UPDATE sde.table_registry
    SET    OBJECT_FLAGS = CASE
                        WHEN MOD(TRUNC(OBJECT_FLAGS / POWER(2, 20)), 2) = 0 THEN
                        OBJECT_FLAGS + POWER(2, 20)
                        ELSE OBJECT_FLAGS
                      END
    WHERE  REGISTRATION_ID = (select registration_id from sde.table_registry
                              where owner = 'xxOWNERxx'
                              and table_name = 'xxFEATURECLASSxx_H');
    ```

    The record in SDE.SDE_ARCHIVES needs to be populated.

    Archive date should be set to archive_date in the source or sde.table_registry.registration_date of the source _H table. Verify that these values are equal. 

    ```sql
    insert into sde.sde_archives
        (archiving_regid --parents regid
        ,history_regid   --history regid
        ,from_date
        ,to_date
        ,archive_date
        ,archive_flags)
    values (
        (select registration_id 
            from sde.table_registry where owner = USER
            and table_name = 'xxFEATURECLASSxx')
        ,(select registration_id 
            from sde.table_registry where owner = USER
            and table_name = 'xxFEATURECLASSxx_H')
        ,'GDB_FROM_DATE'
        ,'GDB_TO_DATE'
        ,1234567890 --todo: unix epoch time in seconds should be same as source?
        ,0
    );
    ```


### Approach 3: Direct Load Target History Tables

1. Copy the feature class to a file geodatabase. Perform any required sprucing up in the file geodatabase.

2.	Copy the feature class from the file geodatabase to the target schema. It will be registered with the geodatabase. Register as versioned.  Register as archiving.

3. Verify expected tolerance and resolution.

4. Target: Truncate the _H table. 

5.	Source: Unset IS_HISTORY to make source _H table visible to ESRI software.

The ID in the where clause below is of the history table not the featureclass.

```sql
-- Unset IS_HISTORY
UPDATE sde.table_registry
SET    OBJECT_FLAGS = CASE
                        WHEN MOD(TRUNC(OBJECT_FLAGS / POWER(2, 20)), 2) = 1 THEN
                        OBJECT_FLAGS - POWER(2, 20)
                        ELSE OBJECT_FLAGS
                      END
WHERE  REGISTRATION_ID = <HISTORY_REGID from SDE.SDE_ARCHIVES>;
```

Commit and refresh ESRI software.

6. Target: Unset IS_HISTORY to make the target _H table visible to ESRI software.

```sql
-- Unset IS_HISTORY
UPDATE sde.table_registry
SET    OBJECT_FLAGS = CASE
                        WHEN MOD(TRUNC(OBJECT_FLAGS / POWER(2, 20)), 2) = 1 THEN
                        OBJECT_FLAGS - POWER(2, 20)
                        ELSE OBJECT_FLAGS
                      END
WHERE  REGISTRATION_ID = <HISTORY_REGID from SDE.SDE_ARCHIVES>;
```

7. Direct load the _H table on the target from source

    Possible risk: The history geometries do not pass through the file geodatabase and any updates related to tolerance and resolution.

    This does not appear to work. See https://github.com/mattyschell/cscl-migrate/issues/6


8. Source: set is_history back to 1 to restore archiving

```sql
-- Set IS_HISTORY
UPDATE 
    sde.table_registry
SET 
    OBJECT_FLAGS = CASE
                       WHEN MOD(TRUNC(OBJECT_FLAGS / POWER(2, 20)), 2) = 0 
                       THEN
                          OBJECT_FLAGS + POWER(2, 20)
                       ELSE OBJECT_FLAGS
                   END
WHERE  
    REGISTRATION_ID = <HISTORY_REGID from SDE.SDE_ARCHIVES>; 
```

9. Target: objectid update 

    TBD. Recently we have discussed bringing the full universe of (objectid,globalid) pairs from the source and updating base and _H table objectids to match the source.

    What about the .NEXT objectid after this? Do we need to attend to a database sequence?


10. Target: Set IS_HISTORY to re-hide the _H

    The ARCHIVING feature class or table should already have its IS_ARCHIVING bit (bit 18 zero-based) set.  Confirm this. 

    The HISTORY feature class or table has to have IS_HISTORY (bit 20) set.

    ```sql
    UPDATE sde.table_registry
    SET    OBJECT_FLAGS = CASE
                        WHEN MOD(TRUNC(OBJECT_FLAGS / POWER(2, 20)), 2) = 0 THEN
                        OBJECT_FLAGS + POWER(2, 20)
                        ELSE OBJECT_FLAGS
                      END
    WHERE  REGISTRATION_ID = (select registration_id from sde.table_registry
                              where owner = 'xxOWNERxx'
                              and table_name = 'xxFEATURECLASSxx_H');
    ```

11. Target: Update archive_date 

    The record in SDE.SDE_ARCHIVES needs to be updated.

    Archive date should be set to archive_date in the source.

    Untested:

    ```sql
    update sde.sde_archives
    set
        archive_date = 1234567890 --todo: unix epoch time in seconds from source
    where 
        archiving_regid = xx
    and history_regid = yy;
    ```