CREATE OR REPLACE PACKAGE BODY NYC_ARCHIVE_UTILS
AS

    PROCEDURE fetch_h_table (
        p_featureclass      IN VARCHAR2
       ,p_hregistration_id  OUT NUMBER
       ,p_htable_name       OUT VARCHAR2
    )
    AS

        -- mschell! 20250422

        -- sample call. as the data owner 
        --
        --    declare
        --          featureclass varchar2(64) := 'ADDRESSPOINT';
        --          registrationid number;
        --          htablename varchar2(64);
        --    begin
        --          sde.NYC_ARCHIVE_UTILS.fetch_h_table(featureclass
        --                                             ,registrationid
        --                                             ,htablename);
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
                                         ,SYS_CONTEXT('USERENV','SESSION_USER');

        exception
        when others 
        then
            raise_application_error(-20001, 'ERROR > ' || SQLERRM || ' < on ' 
                                 || psql || ' with binds '
                                 || upper(p_featureclass) || ' ' 
                                 || SYS_CONTEXT('USERENV','SESSION_USER'));
        end;

    END fetch_h_table;


    PROCEDURE reveal_history (
        p_featureclass  IN VARCHAR2
    )
    AS

        -- mschell! 20250423

        -- The ID in the where clause below is of the history table 
        -- not the featureclass. This unsets the IS_HISTORY bit 
        -- to make the (source) _H table visible

        h_registration_id   number;
        h_table_name        varchar2(64);
        psql                varchar2(4000);

    BEGIN

        nyc_archive_utils.fetch_h_table(p_featureclass
                                       ,h_registration_id
                                       ,h_table_name);

        psql := 'update '
             || '    sde.table_registry '
             || 'set '
             || '    object_flags = CASE '
             || '                   WHEN MOD(TRUNC(OBJECT_FLAGS / POWER(2, 20)), 2) = :p1 '
             || '                   THEN '
             || '                        object_flags - POWER(2, 20) '
             || '                   ELSE '
             || '                       object_flags '
             || '                   END '
             || 'where '
             || '    registration_id = :p2 ';

        execute immediate psql using 1
                                    ,h_registration_id;
        commit;

    END reveal_history;


    PROCEDURE conceal_history (
        p_featureclass  IN VARCHAR2
    )
    AS

        -- mschell! 20250423

        h_registration_id   number;
        h_table_name        varchar2(64);
        psql                varchar2(4000);

    BEGIN

        nyc_archive_utils.fetch_h_table(p_featureclass
                                       ,h_registration_id
                                       ,h_table_name);

        psql := 'update '
             || '    sde.table_registry '
             || 'set '
             || '    object_flags = CASE '
             || '                   WHEN MOD(TRUNC(OBJECT_FLAGS / POWER(2, 20)), 2) = :p1 '
             || '                   THEN '
             || '                        object_flags + POWER(2, 20) '
             || '                   ELSE '
             || '                       object_flags '
             || '                   END '
             || 'where '
             || '    registration_id = :p2 ';

        execute immediate psql using 0
                                    ,h_registration_id;
        commit;


    END conceal_history;


    PROCEDURE register_archiving (
        p_featureclass  IN VARCHAR2
       ,p_htable_name   IN VARCHAR2
       ,p_archive_date  IN NUMBER
    )
    AS

        -- mschell! 20250423
        -- call on target database from data owner to sde
        -- p_archive_date comes from the source afaik
        -- "unix epoch time in seconds"
        -- so this is gonna be scripted out for a list of feature classes

        -- sample call as data owner (CSCL)
        -- call sde.register_archiving('ACCESSPOINTSTOENTRANCEPOINTS' ,'ACCESSPOINTSTOENTRANCEPOINTS_H' ,1399742968);
        
        h_registration_id   number;
        psql                varchar2(4000);
        f_registration_id   number;

    BEGIN


        psql := 'select '
             || '    a.registration_id '
             || 'from '
             || '    sde.table_registry a '
             || 'where '
             || '    a.table_name = :p1 '
             || 'and a.owner = :p2 ';
        
        execute immediate psql into f_registration_id
                               using p_featureclass
                                    ,SYS_CONTEXT('USERENV','SESSION_USER');

        execute immediate psql into h_registration_id
                               using p_htable_name
                                    ,SYS_CONTEXT('USERENV','SESSION_USER');

        -- set IS_ARCHIVING bit (bit 18 zero-based) 
        -- for the parent archiving feature class

        psql := 'update '
             || '    sde.table_registry '
             || 'set '
             || '    object_flags = CASE '
             || '                   WHEN mod(trunc(object_flags / power(2, 18)), 2) = :p1 '
             || '                   THEN '
             || '                       object_flags + power(2, 18) '
             || '                   ELSE '
             || '                       object_flags '
             || '                   END '
             || 'where '
             || '    registration_id = :p2 ';

        execute immediate psql using 0
                                    ,f_registration_id;
        commit;

        psql := 'insert into '
             || '   sde.sde_archives ( '
             || '        archiving_regid '
             || '       ,history_regid '
             || '       ,from_date '
             || '       ,to_date '
             || '       ,archive_date '
             || '       ,archive_flags ) '
             ||  'values (  '
             || '        :p1 '
             || '       ,:p2 '
             || '       ,:p3 '
             || '       ,:p4 '
             || '       ,:p5 '
             || '       ,:p6 '
             || '        ) ';
        
        -- if rerun this will fail with a unique constraint violation
        
        execute immediate psql using f_registration_id
                                    ,h_registration_id
                                    ,'GDB_FROM_DATE'
                                    ,'GDB_TO_DATE'
                                    ,p_archive_date
                                    ,0;

        commit;

    END register_archiving;

    PROCEDURE deregister_archiving (
        p_featureclass  IN VARCHAR2
       ,p_htable_name   IN VARCHAR2
    )
    AS

        -- mschell! 20250716
        -- call on target database from data owner to sde
        -- this is intended for teardown
        -- we are reversing archive migration
        -- to teardown the same way we built up
        -- https://github.com/mattyschell/cscl-migrate/issues/26

        -- sample call as data owner (CSCL)
        -- call sde.deregister_archiving('BOROUGH','BOROUGH_H');
        
        h_registration_id   number;
        psql                varchar2(4000);
        f_registration_id   number;

    BEGIN


        psql := 'select '
             || '    a.registration_id '
             || 'from '
             || '    sde.table_registry a '
             || 'where '
             || '    a.table_name = :p1 '
             || 'and a.owner = :p2 ';
        
        execute immediate psql into f_registration_id
                               using p_featureclass
                                    ,SYS_CONTEXT('USERENV','SESSION_USER');

        execute immediate psql into h_registration_id
                               using p_htable_name
                                    ,SYS_CONTEXT('USERENV','SESSION_USER');

        -- unset IS_ARCHIVING bit (bit 18 zero-based) 
        -- for the parent archiving feature class
        -- I assume this impacts the behavior of the parent delete
        -- When we delete there will be no keep/destroy _H table

        psql := 'update '
             || '    sde.table_registry '
             || 'set '
             || '    object_flags = CASE '
             || '                   WHEN mod(trunc(object_flags / power(2, 18)), 2) = :p1 '
             || '                   THEN '
             || '                       object_flags - power(2, 18) '
             || '                   ELSE '
             || '                       object_flags '
             || '                   END '
             || 'where '
             || '    registration_id = :p2 ';

        execute immediate psql using 1
                                    ,f_registration_id;
        commit;

        psql := 'delete from '
             || '    sde.sde_archives a '
             || 'where '
             || '    a.archiving_regid = :p1 '
             || 'and a.history_regid = :p2 ';
        execute immediate psql using f_registration_id
                                    ,h_registration_id;
                                    
        commit;

    END deregister_archiving;


END NYC_ARCHIVE_UTILS;
/