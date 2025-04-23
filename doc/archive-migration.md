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


### Migrate Archive

    In the commit history of this file we started with 3 archive migration approaches. This was originally "approach 2."


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
