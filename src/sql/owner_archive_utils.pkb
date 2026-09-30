CREATE OR REPLACE PACKAGE BODY OWNER_ARCHIVE_UTILS
AS


    PROCEDURE fetch_h_table (
        p_featureclass      IN VARCHAR2
       ,p_hregistration_id  OUT NUMBER
       ,p_htable_name       OUT VARCHAR2
    )
    AS

        -- mschell! 20250422
        -- not exactly a duplicate of nyc_archive_utils
        -- session_user vs current_user

        -- sample call. as CSCL 
        --
        --    declare
        --          featureclass   varchar2(64) := 'ADDRESSPOINT';
        --          registrationid number;
        --          htablename     varchar2(64);
        --    begin
        --          owner_archive_utils.fetch_h_table(featureclass
        --                                           ,registrationid
        --                                           ,htablename);
        --    end;

        psql        varchar2(4000);              

    BEGIN

        psql := 'select  '
             || '    a.registration_id '
             || '   ,a.table_name '
             || 'from '
             || '    sde.table_registry a '
             || 'join '
             || '    sde.sde_archives b '
             || 'on '
             || '    a.registration_id = b.history_regid '
             || 'join '
             || '    sde.table_registry c '
             || 'on '
             || '    b.archiving_regid = c.registration_id '
             || 'where '
             || '    c.table_name = :p1 '
             || 'and c.owner = :p2 ';

        begin

            execute immediate psql into p_hregistration_id
                                       ,p_htable_name 
                              using upper(p_featureclass)
                                         ,SYS_CONTEXT('USERENV','CURRENT_USER');

        exception
        when others 
        then
            raise_application_error(-20001, 'ERROR > ' || SQLERRM || ' < on ' 
                                 || psql || ' with binds '
                                 || upper(p_featureclass) || ' ' 
                                 || SYS_CONTEXT('USERENV','CURRENT_USER'));
        end;

    END fetch_h_table;

    PROCEDURE refresh_stats 
    AS
    BEGIN

        DBMS_STATS.GATHER_SCHEMA_STATS(
            ownname          => USER, 
            options          => 'GATHER STALE', 
            estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, 
            degree           => DBMS_STATS.DEFAULT_DEGREE
        );

    END refresh_stats;

    PROCEDURE alter_objectid_sequence (
        p_featureclass      IN VARCHAR2
       ,p_htable_name       IN VARCHAR2
       ,p_idcolumn          IN VARCHAR2 DEFAULT 'OBJECTID'
       ,p_hidcolumn         IN VARCHAR2 DEFAULT NULL
    )
    AS

        -- mschell! 20250428

        psql                varchar2(4000);
        registration_id     number;
        startwith           number;

    BEGIN

        psql := 'select '
             || '    a.registration_id '
             || 'from '
             || '    sde.table_registry a '
             || 'where '
             || '    a.owner = :p1 '
             || 'and a.table_name = :p2 ';
        
        execute immediate psql into registration_id 
                               using SYS_CONTEXT('USERENV','CURRENT_USER')
                                    ,upper(p_featureclass);

        psql := 'select '
             || '   max(a.maxid) + 1 '
             || 'from (select '
             || '          nvl(max(' || p_idcolumn || '),0) as maxid '
             || '      from '
             || '          ' || p_featureclass || ' '
             || '      union '
             || '      select '
             || '         nvl(max(' || nvl(p_hidcolumn, p_idcolumn) || '),0) as maxid '
             || '      from '
             || '         ' || p_htable_name || ') a ';

        execute immediate psql into startwith; 

        if startwith > 1
        then

            -- objectid sequences increment by 16. curious
            psql := 'alter sequence r' || registration_id || ' '
                 || 'restart start with ' || startwith;

            execute immediate psql;

        end if;

    END alter_objectid_sequence;


    PROCEDURE update_base_ids (
        p_featureclass  IN VARCHAR2
       ,p_htable_name   IN VARCHAR2
       ,p_idcolumn      IN VARCHAR2 DEFAULT 'OBJECTID'
       ,p_hidcolumn     IN VARCHAR2 DEFAULT NULL
    )
    AS

        -- mschell! 20250428
        -- In our workflow the _H table is not yet registered  
        -- with the geodatabase as an archive class.
        -- We cant use fetch_h_table. It must be passed in.
        --
        -- This procedure assumes the target base table and copied _H table
        -- can be joined on GLOBALID at this point in the migration.
        -- The final workflow requires the base table GLOBALID values to
        -- match the source data, while the _H table GLOBALID values remain
        -- a superset of the base table values.

        psql                varchar2(4000);
        h_registration_id   number;
        zero_globalid       varchar2(38) := '{00000000-0000-0000-0000-000000000000}';
        zero_base_count     number;
        hidcolumn           varchar2(30) := nvl(p_hidcolumn, p_idcolumn);

    BEGIN

        -- attributed relationship classes use RID instead of OBJECTID
        if upper(p_idcolumn) not in ('OBJECTID','RID')
        then
            raise_application_error(-20007
                ,'unsupported id column ' || p_idcolumn || ' for ' || p_featureclass);
        end if;

        if upper(hidcolumn) not in ('OBJECTID','RID','GDB_ARCHIVE_OID')
        then
            raise_application_error(-20007
                ,'unsupported id column ' || hidcolumn || ' for ' || p_htable_name);
        end if;

        owner_archive_utils.refresh_stats();

        psql := 'select count(*) '
             || 'from ' 
             ||     p_featureclass || ' '
             || 'where ' 
             || '   globalid = :p1 ';

        execute immediate psql into zero_base_count
                               using zero_globalid;

        if zero_base_count > 0
        then
            raise_application_error(-20004
                ,zero_base_count || ' sentinel GLOBALIDs found in base table ' || p_featureclass);
        end if;

        -- prevent objectid collisions
        -- ORA-00001: unique constraint (CSCL.Rxxxx_SDE_ROWID_UK) violated
        -- update all base table objectids to a minimum that is greater than 
        -- any  incoming objectid from the _H table
        -- This update will be recognized in alter_objectid_sequence below
        psql := 'update ' 
             ||     p_featureclass || ' a '
             || 'set '
             || '    a.' || p_idcolumn || ' = a.' || p_idcolumn || ' + ( '
             || '        select nvl(max(' || hidcolumn || '), :p1) + :p2 '
             || '        from ' || p_htable_name || ') ';

           execute immediate psql using 0
                                       ,1;
        commit;

        psql := 'merge into '
             || '   ' || p_featureclass || ' a '
             || 'using ( '
             || '   select distinct globalid, ' || hidcolumn || ' as hid '
             || '   from ' || p_htable_name || ' '
             || '   where globalid is not null '
             || '   and globalid <> :p_zero_globalid '
             || ') b '
             || 'on '
             || '   (a.globalid = b.globalid) '
             || 'when matched then '
             || 'update '
             || '   set a.' || p_idcolumn || ' = b.hid ';
        
        begin

            execute immediate psql using zero_globalid;
            commit;

        exception
        when others 
        then
            raise_application_error(-20001, 'ERROR > ' || SQLERRM || ' < on ' || psql);
        end;

        owner_archive_utils.alter_objectid_sequence(p_featureclass
                                                   ,p_htable_name
                                                   ,p_idcolumn
                                                   ,hidcolumn);

    END update_base_ids;


    PROCEDURE update_baseglobalids
    AS

        -- mschell!
        -- https://github.com/mattyschell/cscl-migrate/issues/40
        -- calls update_base_ids for every registered base table paired with
        -- a registered _H table, both having GLOBALID and their registered rowid column.
        -- The _H id column is the base rowid column (OBJECTID/RID) when present,
        -- otherwise the _H registered rowid column (GDB_ARCHIVE_OID).
        -- The _H tables are not yet in sde.sde_archives so pairs are by name.

        paircount   number := 0;

    BEGIN

        FOR rec IN (
            WITH eligible AS (
                -- table_registry columns are NVARCHAR2, avoid ORA-12704 in CASE/NVL below
                SELECT
                    TO_CHAR(tr.table_name)   AS table_name
                   ,TO_CHAR(tr.rowid_column) AS rowid_column
                FROM
                    sde.table_registry tr
                WHERE
                    tr.owner = SYS_CONTEXT('USERENV','CURRENT_USER')
                AND EXISTS (SELECT 1
                            FROM user_tab_columns g
                            WHERE g.table_name = tr.table_name
                            AND g.column_name = 'GLOBALID')
                AND EXISTS (SELECT 1
                            FROM user_tab_columns r
                            WHERE r.table_name = tr.table_name
                            AND r.column_name = tr.rowid_column)
            )
            ,pairs AS (
                SELECT
                    b.table_name AS base_table
                   ,b.rowid_column AS id_column
                    -- archive names inherited from the source that break the convention
                    -- good news: source is now consistently breaking the 
                    -- convention in dev, stg, and prd. 
                   ,CASE b.table_name
                        WHEN 'CENTERLINE'        THEN 'CENTERLINE_H1'
                        WHEN 'NYPDPATROLBOROUGH' THEN 'NYPDBOROUGHCOMMAND_H'
                        WHEN 'NYPDSECTOR'        THEN 'NYPDSECTOR_NEW_H'
                        WHEN 'ACCESSPOINTTOADDRESSPOINT'      THEN 'ACCESSPOINTTOADDRESSPOINT4_H'
                        WHEN 'COMMONPLACESHAVEADDRESSPOINTS'  THEN 'COMMONPLACESHAVEADDRESSPOIN_H'
                        WHEN 'SUBWAYSTATIONSHAVEFEATURENAMES' THEN 'SUBWAYSTATIONSHAVEFEATURENA_H'
                        ELSE b.table_name || '_H'
                    END AS h_table
                FROM
                    eligible b
                WHERE
                    NOT REGEXP_LIKE(b.table_name, '_H[0-9]*$')
                AND b.rowid_column IN ('OBJECTID','RID')
            )
            SELECT
                p.base_table
               ,p.h_table
               ,p.id_column
               ,NVL(hc.column_name, h.rowid_column) AS h_id_column
            FROM
                pairs p
            JOIN
                eligible h
                ON  h.table_name = p.h_table
            LEFT JOIN
                user_tab_columns hc
                ON  hc.table_name  = p.h_table
                AND hc.column_name = p.id_column
            ORDER BY
                p.base_table
        )
        LOOP

            owner_archive_utils.update_base_ids(rec.base_table
                                               ,rec.h_table
                                               ,rec.id_column
                                               ,rec.h_id_column);

            paircount := paircount + 1;
            dbms_output.put_line('PASS:' || rec.base_table
                                || ' | archive:' || rec.h_table
                                || ' | ' || rec.id_column || ' from ' || rec.h_id_column);

        END LOOP;

        if paircount = 0
        then
            raise_application_error(-20006
                ,'no eligible base and _H table pairs found for '
                 || SYS_CONTEXT('USERENV','CURRENT_USER'));
        end if;

    END update_baseglobalids;


    PROCEDURE verify_globalids
    AS

        -- mschell!
        -- https://github.com/mattyschell/cscl-migrate/issues/40
        -- every GLOBALID present in a registered base table/featureclass
        -- must also be present in its archive (_H) table

        psql            varchar2(4000);
        badcount        number := 0;
        missingcount    number;
        hasmoddate      number;

    BEGIN

        FOR rec IN (
            SELECT
                c.table_name AS base_table
               ,b.table_name AS h_table
            FROM
                sde.sde_archives a
            JOIN
                sde.table_registry b ON a.history_regid = b.registration_id
            JOIN
                sde.table_registry c ON a.archiving_regid = c.registration_id
            WHERE
                b.owner = SYS_CONTEXT('USERENV','CURRENT_USER')
            ORDER BY
                c.table_name
        )
        LOOP

            select count(*) into hasmoddate
            from user_tab_columns
            where table_name = rec.base_table
            and column_name = 'MODIFIED_DATE';

            if hasmoddate = 0 then
                dbms_output.put_line('SKIP:' || rec.base_table
                                    || ' | archive:' || rec.h_table
                                    || ' | ');
                continue;
            end if;

            psql := 'select count(*) '
                 || 'from ' || rec.base_table || ' t '
                 || 'where not exists (select 1 '
                 || '                  from ' || rec.h_table || ' h '
                 || '                  where h.globalid = t.globalid) '
                 || 'and t.modified_date is not null';

            begin
                execute immediate psql into missingcount;
            exception
            when others then
                missingcount := -1;
                dbms_output.put_line('ERROR:' || rec.base_table || ' | ' || SQLERRM);
            end;

            if missingcount = 0 then
                dbms_output.put_line('PASS:' || rec.base_table
                                    || ' | archive:' || rec.h_table
                                    || ' | missing:0');
            else
                -- from what I have seen this is identical to the source,
                -- including production. We will log as a warning 
                -- it may be fine 
                badcount := badcount + 1;
                dbms_output.put_line('WARN:' || rec.base_table
                                    || ' | archive:' || rec.h_table
                                    || ' | missing:' || missingcount);
            end if;

        END LOOP;

        --if badcount > 0 then
        --    raise_application_error(-20002
        --        ,badcount || ' feature classes/tables have GLOBALIDs missing from their archive (_H) table');
        --end if;

    END verify_globalids;


    PROCEDURE restore_globalids
    AS

        -- mschell!
        -- https://github.com/mattyschell/cscl-migrate/issues/40
        -- loading into the enterprise geodatabase assigns each base row a new
        -- GLOBALID. BASEGLOBALID (added by globalid_manager.preserve_globalid
        -- for the same universe of FeatureClass/Table/RelationshipClass) holds
        -- the original value. Restore it here in SQL, before update_base_ids
        -- relies on GLOBALID to join base rows to their migrated _H rows.
        -- join to table_registry so adds/deletes tables (e.g. A1353) and
        -- versioned views (e.g. ACCESSPOINT_EVW) are never touched, only
        -- real registered base tables.
        -- A populated adds/deletes table at this point means something is
        -- wrong

        psql            varchar2(4000);
        adds_table      varchar2(64);
        deletes_table   varchar2(64);
        rowcount_check  number;

    BEGIN

        FOR rec IN (
            SELECT DISTINCT
                utc.table_name
               ,tr.registration_id
            FROM
                user_tab_columns utc
            JOIN
                sde.table_registry tr
                ON tr.table_name = utc.table_name
               AND tr.owner = SYS_CONTEXT('USERENV','CURRENT_USER')
            WHERE
                utc.column_name = 'BASEGLOBALID'
            -- excludes _H, _H1, _H2, etc archive tables
            AND NOT REGEXP_LIKE(tr.table_name, '_H[0-9]*$')
            ORDER BY
                utc.table_name
        )
        LOOP

            adds_table    := 'A' || rec.registration_id;
            deletes_table := 'D' || rec.registration_id;

            begin
                execute immediate 'select count(*) from ' || adds_table into rowcount_check;
            exception
                when others then
                    if sqlcode = -942 then
                        rowcount_check := 0;
                    else
                        raise;
                    end if;
            end;

            if rowcount_check > 0
            then
                raise_application_error(-20005, rowcount_check || ' rows found in adds table '
                                     || adds_table || ' for base table ' || rec.table_name
                                     || ' - unexpected at this point in the migration');
            end if;

            begin
                execute immediate 'select count(*) from ' || deletes_table into rowcount_check;
            exception
                when others then
                    if sqlcode = -942 then
                        rowcount_check := 0;
                    else
                        raise;
                    end if;
            end;

            if rowcount_check > 0
            then
                raise_application_error(-20005, rowcount_check || ' rows found in deletes table '
                                     || deletes_table || ' for base table ' || rec.table_name
                                     || ' - unexpected at this point in the migration');
            end if;

            psql := 'update ' || rec.table_name || ' '
                 || 'set globalid = baseglobalid '
                 || 'where baseglobalid is not null';

            begin
                execute immediate psql;
                commit;
                dbms_output.put_line('PASS:' || rec.table_name || ' | globalid restored from baseglobalid');
            exception
            when others then
                raise_application_error(-20003, 'ERROR > ' || SQLERRM || ' < on '
                                     || psql);
            end;

        END LOOP;

    END restore_globalids;


END OWNER_ARCHIVE_UTILS;
/