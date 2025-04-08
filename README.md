## cscl-migrate

We wish to migrate the New York City Citywide Street Centerline (CSCL) database from its legacy environment to some fancy new environments. Friends this our CSCL migration, our rules, the trick is never to be afraid.

See also related https://github.com/mattyschell/cscl-refresh. 

The New York City Department of City Planning will produce the editing software in the target environment.  This repo is initially focused on migrating data to support this future software development.

### Overall Migration Plan

For now see [doc/bigpicture.md](doc/bigpicture.md)

### 1. Extract and Prepare CSCL

Review and update the environmentals.

```sh
> geodatabase-scripts\sample-cscl-extract.bat
```

What does that do?  Glad you asked. 

It creates an empty file geodatabase. Then it use python 2 arcpy with class extension readers to copy/paste from the Enterprise Geodatabase to cscl-migrate.gdb. 

    \[dev|stg|prd]\cscl-migrate.gdb


### 2. Remove class extensions from the file geodatabase

TOP SECRET

### 3. Correct resolution and tolerance

Review and update the environmentals.

```
> geodatabase-scripts\sample-reprojectgdb.bat
```

### 4. Migrate Archive Classes

For now see [doc/archive-migration.md](doc/archive-migration.md)


### 5. Load to final Enterprise Geodatabase

TBD




