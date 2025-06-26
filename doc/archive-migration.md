## Migrating Archive Classes

We will migrate CSCL via an interim step like a file geodatabase.  In this interim step we will lose the archive.

The CSCL maintenance team uses the archive to investigate the source of bad data.  There are also expectations for data retention from public safety outfits and next generation 911.

The steps below describe our preferred archive restoration strategy. This strategy is not supported by the COTS software.

See the src/py/resources directory of this repo for lists of CSCL feature classes and tables.  Consider stupid simple generating scripts by starting with these lists and typing out the actions in "column mode" of a text editor. 

### Confirm All Datasets Have a Globalid

Objectid gets toasted on the target. Globalids will serve as a persistent unique identifier.

See doc\confirm-globalid.sql for helper sql.

### Compile Packages

Compile 2 packages in 3 schemas. SDE source, SDE target, and data owner target.

```bat
sqlplus sde/****@srcdb @geodatabase-scripts\setup-sde-source.sql
sqlplus sde/****@targetdb @geodatabase-scripts\setup-sde-target.sql
sqlplus cscl/****@targetdb @geodatabase-scripts\setup-owner-target.sql
```

### Migrate Archive

In the commit history of this file we started with 3 archive migration approaches. This was originally "approach 2."

1.	Copy the feature class to the target schema. It will be registered with the geodatabase. Register as versioned.  Do not register as archiving.

In the real workflow the data will move to the target via an interim file geodatabase or two. The file geodatabase processing will involve all datasets and can take place prior to or in parallel to the archive steps below.

2.	Source: Make the _H table visible to ESRI clients.

Call from CSCL to this utility in SDE. Then refresh the ESRI client to see the _H table.

```sql
call sde.nyc_archive_utils.reveal_history('BOROUGH');
```

3.	Copy the _H table to target schema using 32 bit ESRI clients and paste-NOT-special. It will be named FEATURECLASSNAME_H just like the source.

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

6. Target: Manually “register” the parent as archiving and _H table is the history table.  Call from CSCL to this utility in SDE.

Archive date should be set to archive_date in the source sde.table_registry. 

```sql
call sde.nyc_archive_utils.register_archiving('BOROUGH',1273245334);
```

The copied _H table must be concealed. Call from CSCL on the target.

```sql
call sde.nyc_archive_utils.conceal_history('BOROUGH');
```
