## cscl-migrate

We wish to migrate the New York City Citywide Street Centerline (CSCL) database from its legacy environment to some fancy new environments. Friends this our CSCL migration, our rules, the trick is never to be afraid.

See also related https://github.com/mattyschell/cscl-refresh. 

The New York City Department of City Planning will produce the editing software in the target environment.  This repo is initially focused on migrating data to support their software development.

### Overall Migration Plan

For now see [doc/bigpicture.md](doc/bigpicture.md)

### Extract and Prepare CSCL

1. Create an empty file geodatabase. Convention:

    \[dev|stg|prd]\cscl-migrate.gdb

2. Use python 2 arcpy with class extension readers to copy/paste from the Enterprise Geodatabase to the file geodatabase

3. Remove class extensions from the file geodatabase

4. Run reproject code on the file geodatabase

### Migrate Archive Classes

For now see [doc/archive-migration.md](doc/archive-migration.md)


### Special Reproject Step to Correct Resolution and Tolerannce.




