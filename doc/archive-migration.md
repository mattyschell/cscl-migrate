## Migrating Archive Classes

We wish to migrate CSCL via an interim step like a file geodatabase.  In this interim step we will lose the archive.

The steps below describe our preferred archive restoration strategy. This strategy is not supported by the COTS software.

See the src/py/resources directory of this repo for lists of CSCL feature classes and tables.  Consider stupid simple generating scripts by starting with these lists and typing out the actions in "column mode" of a text editor. 

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


### Migrate Archive Manual Steps

In the commit history of this file we started with 3 archive migration approaches. This was originally "approach 2."

1.	Copy the feature class to a target schema. It will be registered with the geodatabase. Register as versioned.  Do not register as archiving.

In the real workflow the data will move to an interim file geodatabase here.

2.	Source: Make the _H table visible to ESRI clients.

Call from CSCL to this utility in SDE. Then refresh the ESRI client to see the _H table.

```sql
call sde.nyc_archive_utils.reveal_history('BOROUGH');
```

3.	Copy the _H table to target schema and paste-NOT-special. It will be named xxFEATURECLASSxx_H

It may be necessary to use FeatureClassToGeodatabase instead of copy paste.

4. Source: Hide _H table from ESRI clients.

```sql
call sde.nyc_archive_utils.conceal_history('BOROUGH');
```

5. Target: objectid update 

The row count in the base table should be less than the _H table. The _H table contains a superset of all possible objectids. Unmatched objectids will exist in _H. This is OK they are history.

Since objectids don't matter to anyone (they are synthetic keys) we will update the base table objectids to match their _H table bretheren and sisteren. Then restart the feature class objectid sequence.

```sql
call owner_archive_utils.update_base_ids('BOROUGH');
```

6. Target: Manually “register” the parent as archiving and _H table is the history table as follows


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

The copied _H table has to be made history. Call from CSCL to this utility in SDE. 

```sql
call sde.nyc_archive_utils.conceal_history('BOROUGH');
```

TODO: Test this and replace docs with package call

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
