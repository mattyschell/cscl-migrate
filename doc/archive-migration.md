## Migrating Archive Classes

We will migrate CSCL via an interim step like a file geodatabase.  In this interim step we will lose the archive.

The CSCL maintenance team uses the archive to investigate the source of bad data.  There are also expectations for data retention from public safety outfits and next generation 911.

The steps below describe our preferred archive restoration strategy. This strategy is not supported by the COTS software.

### Confirm All Datasets Have a Globalid

The geodatabase does not guarantee objectid consistency during the base data migration. Globalids will serve as a persistent unique identifier.

At the conclusion of the migration, the base table must retain its source GLOBALID values in a column named GLOBALID. The copied _H table must also retain a column named GLOBALID and should contain a superset of the base table GLOBALIDs.

This requirement is the hard part of the workflow. The file geodatabase reprojection step creates fresh target GlobalIDs during load, so the source GlobalIDs must either survive the intermediate processing directly or be restored later without damaging geodatabase behavior.

See doc\confirm-globalid.sql for helper sql.

![Archive issue](archive-issue.png)

### Compile Packages

Compile 2 packages in 3 schemas. SDE source, SDE target, and data owner target.

```bat
sqlplus sde/****@srcdb @geodatabase-scripts\setup-sde-source.sql
sqlplus sde/****@targetdb @geodatabase-scripts\setup-sde-target.sql
sqlplus cscl/****@targetdb @geodatabase-scripts\setup-owner-target.sql
```

### Migrate Archive

In the commit history of this file we started with 3 archive migration strategies. The core of this strategy we creatively named "approach 2." 

![Archive issue plan](archive-issue-plan.png)

#### Migrate Archive: Base Tables

The base table will move to the target via an interim file geodatabase or two. The file geodatabase processing includes all datasets.

During this base table migration we must preserve the source GLOBALID values for each base table so they can be restored to the target base table GLOBALID column. The target base tables created by the reprojection process will otherwise contain fresh managed GLOBALIDs.

1.	Copy the base table feature class from the file geodatabase to the target schema. It will be registered with the geodatabase. 

2. Register the base table feature class as versioned. Do not register as archiving.

3. Transfer temporary BASEGLOBALIDs to GLOBALID.

4. Using arcpy DeleteField, drop the BASEGLOBALID column.

#### Migrate Archive: History Tables

1.	Source database: Make the _H table visible to ESRI clients.

Call from CSCL to this utility in SDE. Then refresh the ESRI client to see the _H table.

```sql
call sde.nyc_archive_utils.reveal_history('BOROUGH');
```

2. Copy the _H table to the target database schema using 32 bit ESRI clients and paste (using arcpy). It will be named FEATURECLASSNAME_H (or similar) just like the source.

3. Source database: Hide the _H table from ESRI clients.

```sql
call sde.nyc_archive_utils.conceal_history('BOROUGH');
```

#### Migrate Archive: Objectid Updates

The base and _H tables hold different record sets. Unmatched objectids will exist on both sides. This is OK and expected (see diagrams).

Geodatabase objectids are synthetic keys with no expectation that they will remain attached to a row. What matters is that the values match internally in the geodatabase.  We will update the base table objectids where necessary. 

1. Prevent collisions by updating all base table OBJECTIDs to a value greater than the maximum _H table OBJECTID.
2. Joining on GLOBALID, update base table OBJECTIDs to match their _H table bretheren and sisteren.
3. Alter the feature class OBJECTID sequence (RXXXX).

All three are in this stored procedure.

```sql
call owner_archive_utils.update_base_ids('BOROUGH');
```

#### Finalize Geodatabase Archive

On the target database “register” the parent as archiving and the _H table as the history table. Call from CSCL to this utility in SDE.

The archive date (parameter 2) should be set to the archive_date in the source sde.table_registry. 

```sql
call sde.nyc_archive_utils.register_archiving('BOROUGH',1273245334);
```
The copied _H table must be concealed. Call from CSCL on the target.

```sql
call sde.nyc_archive_utils.conceal_history('BOROUGH');
```
