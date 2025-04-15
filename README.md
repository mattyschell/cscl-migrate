## cscl-migrate

We wish to migrate the New York City Citywide Street Centerline (CSCL) database from its legacy environment to some fancy new environments. Friends this our CSCL migration, our rules, the trick is never to be afraid.

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

With ArcCatalog 10.7 or superior

1. Clone https://github.com/nicogis/RemoveClassExtension
2. As admin (?) and with ArcCatalog closed (?) double click "Config.esriaddinx"
3. Nothing will happen. 
4. From ArcCatalog add a new toolbar (customize-toolbars-customize)
5. From ArcCatalog Customize - AddIn Manager - Select ResetCLSIDs - Click Customize
6. Select the Commands tab and search for "Reset CLSIDs." Drag it to the new toolbar

DANGER ZONE

7. Select the file geodatabase and run the AddIn.
8. Review the log. It should look (confusingly) like the snippet below
9. Remove the toolbar.  CODE YELLOW

```
Inspecting item 'STREETSHAVEINTERSECTIONS', OID: 82
	Expected CLSID equals Actual CLSID, no change needed.
	Expected EXTCLSID: 
	Actual EXTCLSID: {19DC51F2-D817-4623-BBEA-FB5E0A88385E}
Inspecting item 'COMPLEXINTERSECTION', OID: 83
	Expected CLSID equals Actual CLSID, no change needed.
	Expected EXTCLSID equals Actual EXTCLSID, no change needed.
```



### 3. Correct resolution and tolerance

Review and update the environmentals.

```
> geodatabase-scripts\sample-reprojectgdb.bat
```

### 4. Migrate Archive Classes

For now see [doc/archive-migration.md](doc/archive-migration.md)


### 5. Load to final Enterprise Geodatabase

TBD




