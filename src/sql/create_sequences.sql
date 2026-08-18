WHENEVER SQLERROR EXIT SQL.SQLCODE;

CREATE OR REPLACE PROCEDURE create_cscl_seq (
    p_sequence_name IN VARCHAR2,
    p_table_columns IN VARCHAR2  -- comma-delimited list 'table1.column1,.. '
) AS
    v_max_value     NUMBER := 0;
    v_current_max   NUMBER;
    v_pair          VARCHAR2(256);
    v_table_name    VARCHAR2(128);
    v_column_name   VARCHAR2(128);
    v_start_pos     NUMBER := 1;
    v_end_pos       NUMBER;
    v_dot_pos       NUMBER;
    psql            VARCHAR2(4000);
BEGIN
    -- Parse comma-delimited list and find max across all table.column pairs
    LOOP
        -- Find next comma or end of string
        v_end_pos := INSTR(p_table_columns
                          ,','
                          ,v_start_pos);
        
        IF v_end_pos = 0 
        THEN
            -- Last pair
            v_pair := TRIM(SUBSTR(p_table_columns, v_start_pos));
        ELSE
            -- Extract pair between commas
            v_pair := TRIM(SUBSTR(p_table_columns, v_start_pos, v_end_pos - v_start_pos));
        END IF;
        
        EXIT WHEN v_pair IS NULL OR v_pair = '';
        
        -- Parse table.column pair
        v_dot_pos := INSTR(v_pair, '.');
        
        IF v_dot_pos = 0 
        THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid format in table.column pair: ' || v_pair || 
                                            '. Expected format: table.column');
        END IF;
        
        v_table_name := LOWER(TRIM(SUBSTR(v_pair, 1, v_dot_pos - 1)));
        v_column_name := LOWER(TRIM(SUBSTR(v_pair, v_dot_pos + 1)));

        -- Get max value from this table.column
        BEGIN
            EXECUTE IMMEDIATE
                'SELECT COALESCE(MAX(' || v_column_name || '), 0) FROM ' || v_table_name
            INTO v_current_max;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(
                    -20003,
                    'Failed to read MAX(' || v_column_name || ') from table ' || v_table_name ||
                    '. Source pair: ' || v_table_name || '.' || v_column_name ||
                    '. Original error: ' || SQLERRM
                );
        END;
        
        -- Track the overall maximum
        IF v_current_max > v_max_value 
        THEN
            v_max_value := v_current_max;
        END IF;
        
        -- Exit if no more pairs
        EXIT WHEN v_end_pos = 0;
        
        -- Move to next pair
        v_start_pos := v_end_pos + 1;
    END LOOP;
    
    -- Create sequence with start value of (max value + 1)

    -- This will fail with ORA-01031: insufficient privileges
    -- if "create sequence" is granted through a role

    -- The legacy databases used a variety of maxvalues, minvalues, and
    -- caches. I dont see any evidence that this was thought out or designed.
    -- Probably different people copying from stackoverflow and taking guesses.
    -- We will be consistent 

    psql := 'CREATE SEQUENCE "' || UPPER(p_sequence_name) 
         || '" START WITH ' || (v_max_value + 1) 
         || ' INCREMENT BY 1 NOMAXVALUE CACHE 20';
    EXECUTE IMMEDIATE psql;

    -- Grant select on sequence to public
    psql := 'GRANT SELECT ON "' || UPPER(p_sequence_name) 
         || '" TO "PUBLIC"';
    EXECUTE IMMEDIATE psql;

EXCEPTION
    WHEN OTHERS 
    THEN
        IF SQLCODE = -1031 
        THEN
            RAISE_APPLICATION_ERROR(
                -20002,
                'ORA-01031: insufficient privileges while creating or granting sequence "' ||
                UPPER(p_sequence_name) ||
                '". CREATE SEQUENCE may be granted through a role; stored PL/SQL requires the privilege ' ||
                'to be granted directly to the procedure owner. Original error: ' || SQLERRM
            );
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    -- these were not used in the legacy system
    -- we will not create them unless we have a requirement 
    --create_cscl_seq('SEGMENTID');
    --create_cscl_seq('SEQ_LDF_ID');
    --
    create_cscl_seq('SEQ_ACCESSPOINT_ID'
                   ,'ACCESSPOINT_EVW.ACCESSPOINTID');
    create_cscl_seq('SEQ_ADDRESSPOINT_ID'
                   ,'ADDRESSPOINT_EVW.ADDRESSPOINTID');
    create_cscl_seq('SEQ_COMMONPLACE_ID'
                   ,'COMMONPLACE_EVW.PLACEID');
    -- COMPLEXACCESSPOINT is empty
    create_cscl_seq('SEQ_COMPACCESSPOINT_ID'
                   ,'COMPLEXACCESSPOINT_EVW.COMPLEXACCESSPOINTID');
    create_cscl_seq('SEQ_COMPLEX_ID'
                   ,'COMPLEX_EVW.COMPLEXID');
    create_cscl_seq('SEQ_ENTRANCEPOINT_ID'
                   ,'ENTRANCEPOINT_EVW.ENTRANCEPOINTID');
    create_cscl_seq('SEQ_FEATURENAMEID'
                   ,'FEATURENAME_EVW.FEATURENAMEID');
    create_cscl_seq('SEQ_GENERIC_ID'
                   ,'CENTERLINE_EVW.GENERICID');
    create_cscl_seq('SEQ_LDF_NUM'
                   ,'CENTERLINEHISTORY_EVW.LDF_NUM');
    create_cscl_seq('SEQ_LINK_ID'
                   ,'FEATURENAME_EVW.LINKID,COMMONPLACESHAVEFEATURENAMES.LINKID,RAILSTATIONSHAVEFEATURENAMES.LINKID,SUBWAYSTATIONSHAVEFEATURENAMES.LINKID');
    create_cscl_seq('SEQ_NODE_ID'
                   ,'NODE_EVW.NODEID');
    create_cscl_seq('SEQ_NYPD_ID'
                   ,'CENTERLINE_EVW.NYPDID');
    create_cscl_seq('SEQ_PHYSICAL_ID'
                   ,'CENTERLINE_EVW.PHYSICALID');
    create_cscl_seq('SEQ_RAIL_SUBWAY'
                   ,'RAIL_EVW.SEGMENTID,SUBWAY_EVW.SEGMENTID');
    create_cscl_seq('SEQ_RAILSTATION_ID'
                   ,'RAILSTATION_EVW.RAILSTATIONID');
    create_cscl_seq('SEQ_SEGMENT_ID'
                   ,'CENTERLINE_EVW.SEGMENTID,SHORELINE_EVW.SEGMENTID,NONSTREETFEATURE_EVW.SEGMENTID,RAIL_EVW.SEGMENTID,SUBWAY_EVW.SEGMENTID');
    create_cscl_seq('SEQ_STREETNAMEID'
                   ,'STREETNAME_EVW.STREETNAMEID');
    create_cscl_seq('SEQ_SUBWAYSTATION_ID'
                   ,'SUBWAYSTATION_EVW.SUBWAYSTATIONID');
    create_cscl_seq('SEQ_TRANSITBOOTH_ID'
                   ,'TRANSITBOOTH_EVW.TRANSITBOOTHID');
    create_cscl_seq('SEQ_TRANSITEMERGENCY_ID'
                   ,'TRANSITEMERGENCYEXIT_EVW.EMERGENCYEXITID');
    create_cscl_seq('SEQ_TRANSITENTRANCE_ID'
                   ,'TRANSITENTRANCE_EVW.ENTRANCEID');
    -- TURNRESTRICTION and TURNRESTRICTIONLIMITS are empty
    create_cscl_seq('SEQ_TURNID'
                   ,'TURNRESTRICTION_EVW.TURNID,TURNRESTRICTIONLIMITS_EVW.TURNID');
END;
/

DECLARE
    v_missing_sequences VARCHAR2(4000);
BEGIN
    FOR seq IN (
        SELECT column_value AS sequence_name
        FROM TABLE(sys.odcivarchar2list(
            'SEQ_ACCESSPOINT_ID',
            'SEQ_ADDRESSPOINT_ID',
            'SEQ_COMMONPLACE_ID',
            'SEQ_COMPACCESSPOINT_ID',
            'SEQ_COMPLEX_ID',
            'SEQ_ENTRANCEPOINT_ID',
            'SEQ_FEATURENAMEID',
            'SEQ_GENERIC_ID',
            'SEQ_LDF_NUM',
            'SEQ_LINK_ID',
            'SEQ_NODE_ID',
            'SEQ_NYPD_ID',
            'SEQ_PHYSICAL_ID',
            'SEQ_RAIL_SUBWAY',
            'SEQ_RAILSTATION_ID',
            'SEQ_SEGMENT_ID',
            'SEQ_STREETNAMEID',
            'SEQ_SUBWAYSTATION_ID',
            'SEQ_TRANSITBOOTH_ID',
            'SEQ_TRANSITEMERGENCY_ID',
            'SEQ_TRANSITENTRANCE_ID',
            'SEQ_TURNIDS'
        ))
        MINUS
        SELECT sequence_name
        FROM user_sequences
    ) LOOP
        v_missing_sequences := v_missing_sequences ||
            CASE
                WHEN v_missing_sequences IS NULL THEN NULL
                ELSE ', '
            END || seq.sequence_name;
    END LOOP;

    IF v_missing_sequences IS NOT NULL
    THEN
        RAISE_APPLICATION_ERROR(
            -20004,
            'Missing CSCL sequence(s): ' || v_missing_sequences
        );
    END IF;
END;
/

drop procedure create_cscl_seq;


EXIT
