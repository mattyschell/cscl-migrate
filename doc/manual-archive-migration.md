## 6. Manually Migrate Failed Archive Classes

This section may not be applicable. 

### 6a. Manually Migrate Catastrophically Failed Archive Classes

Review the archive migration logs, especially the final verifycounts-*.log. Some _H tables may fail to transfer. Don't read into the ESRI errors that indicate memory issues and so forth.  "Memory" in this context appears to refer to some sort of internal constructor step, not memory exhaustion.

We will use HURRICANEEVACUATIONZONE in the examples below. 

1. Source: Reveal the _H table. From an SQL prompt connected as CSCL.

```sql
> call sde.nyc_archive_utils.reveal_history('HURRICANEEVACUATIONZONE');
```

2. Using ArcCatalog classic ([reminder why](https://github.com/mattyschell/cscl-migrate/issues/11)) manually copy/paste HURRICANEEVACUATIONZONE_H from source to target. This step may take a suspiciously long time. 

3. Target: Update the values in src/sql/sample_finalize_one_archive.sql or use a premade src\sql\finalize_*_archive.sql script if we have been through these steps before.

```bat
> sqlplus %TARGETSCHEMA%/"%TARGETPASSWORD%"@%TARGETDB% @src/sql/sample_finalize_one_archive.sql
```

4. Source: Conceal the history table

```sql
> call sde.nyc_archive_utils.conceal_history('HURRICANEEVACUATIONZONE');
```

### 6b. Manually Migrate Partially Transferred Archive Classes

These steps apply to _H tables that exist and are populated with some, but not all, rows. We will use SCHOOLDISTRICT as the example. 

The steps must be followed precisely ([details](https://github.com/mattyschell/cscl-migrate/issues/28)). 

1. Target: Using ArcGIS Pro disable archiving and choose the option to delete the _H table

2. Source: Reveal the _H table. From an SQL prompt connected as CSCL.

```sql
> call sde.nyc_archive_utils.reveal_history('SCHOOLDISTRICT');
```

3. Using ArcCatalog classic ([reminder why](https://github.com/mattyschell/cscl-migrate/issues/11)) manually copy/paste SCHOOLDISTRICT from source to target. This step may take a suspiciously long time. 

4. Target: Update the values in src\sql\sample_finalize_one_archive.sql or use a premade src\sql\finalize_*_archive.sql script if it exists.

```bat
> sqlplus %TARGETSCHEMA%/"%TARGETPASSWORD%"@%TARGETDB% @src/sql/sample_finalize_one_archive.sql
```

5. Source: Conceal the history table

```sql
> call sde.nyc_archive_utils.conceal_history('SCHOOLDISTRICT');
```

Return to the next step in the [README.md](../README.md)
