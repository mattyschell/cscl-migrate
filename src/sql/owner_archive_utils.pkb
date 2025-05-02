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
             || '          max(objectid) as maxid '
             || '      from '
             || '          ' || p_featureclass || ' '
             || '      union '
             || '      select '
             || '         max(objectid) as maxid '
             || '      from '
             || '         ' || p_htable_name || ') a ';

        execute immediate psql into startwith; 

        -- objectid sequences increment by 16. curious
        psql := 'alter sequence r' || registration_id || ' '
             || 'restart start with ' || startwith;

        execute immediate psql;

    END alter_objectid_sequence;


    PROCEDURE update_base_ids (
        p_featureclass  IN VARCHAR2
    )
    AS

        -- mschell! 20250428

        psql                varchar2(4000);
        h_registration_id   number;
        h_table_name        varchar2(64);

    BEGIN

        owner_archive_utils.refresh_stats();

        -- _H table is not in sde.sde_archives at this point
        h_table_name := p_featureclass || '_H';

        psql := 'merge into '
             || '   ' || p_featureclass || ' a '
             || 'using '
             || '   ' || h_table_name || ' b '
             || 'on '
             || '   (a.globalid = b.globalid) '
             || 'when matched then '
             || 'update '
             || '   set a.objectid = b.objectid ';
        
        begin

            execute immediate psql;
            commit;

        exception
        when others 
        then
            raise_application_error(-20001, 'ERROR > ' || SQLERRM || ' < on ' 
                                          || psql);
        end;

        owner_archive_utils.alter_objectid_sequence(p_featureclass
                                                   ,h_table_name);

    END update_base_ids;


END OWNER_ARCHIVE_UTILS;
/