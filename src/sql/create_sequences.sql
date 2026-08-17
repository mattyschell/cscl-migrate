WHENEVER SQLERROR EXIT SQL.SQLCODE;

CREATE OR REPLACE PROCEDURE create_cscl_seq (
    p_sequence_name IN VARCHAR2,
    p_table_columns IN VARCHAR2  -- comma-delimited list 'table1.column1,.. '
) AS
    v_max_value NUMBER := 0;
    v_current_max NUMBER;
    v_pair VARCHAR2(256);
    v_table_name VARCHAR2(128);
    v_column_name VARCHAR2(128);
    v_start_pos NUMBER := 1;
    v_end_pos NUMBER;
    v_dot_pos NUMBER;
BEGIN
    -- Parse comma-delimited list and find max across all table.column pairs
    LOOP
        -- Find next comma or end of string
        v_end_pos := INSTR(p_table_columns, ',', v_start_pos);
        
        IF v_end_pos = 0 THEN
            -- Last pair
            v_pair := TRIM(SUBSTR(p_table_columns, v_start_pos));
        ELSE
            -- Extract pair between commas
            v_pair := TRIM(SUBSTR(p_table_columns, v_start_pos, v_end_pos - v_start_pos));
        END IF;
        
        EXIT WHEN v_pair IS NULL OR v_pair = '';
        
        -- Parse table.column pair
        v_dot_pos := INSTR(v_pair, '.');
        IF v_dot_pos = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid format in table.column pair: ' || v_pair || 
                                             '. Expected format: table.column');
        END IF;
        
        v_table_name := LOWER(TRIM(SUBSTR(v_pair, 1, v_dot_pos - 1)));
        v_column_name := LOWER(TRIM(SUBSTR(v_pair, v_dot_pos + 1)));
        
        -- Get max value from this table.column
        EXECUTE IMMEDIATE 'SELECT COALESCE(MAX(' || v_column_name || '), 0) FROM ' || v_table_name
            INTO v_current_max;
        
        -- Track the overall maximum
        IF v_current_max > v_max_value THEN
            v_max_value := v_current_max;
        END IF;
        
        -- Exit if no more pairs
        EXIT WHEN v_end_pos = 0;
        
        -- Move to next pair
        v_start_pos := v_end_pos + 1;
    END LOOP;
    
    -- Create sequence with start value = max value + 1
    -- This will fail with ORA-01031: insufficient privileges
    -- if "create sequence" is granted through a role
    EXECUTE IMMEDIATE 'CREATE SEQUENCE "' || UPPER(p_sequence_name) 
                   || '" START WITH ' || (v_max_value + 1) 
                   || ' INCREMENT BY 1 NOMAXVALUE CACHE 20';
    
    -- Grant select on sequence to public
    EXECUTE IMMEDIATE 'GRANT SELECT ON "' || UPPER(p_sequence_name) 
                   || '" TO "PUBLIC"';
EXCEPTION
    WHEN OTHERS THEN
        -- Raise appropriate errors - creation should always succeed
        RAISE;
END;
/

begin
  -- these were not used in the legacy system
  -- we will not create them until we have a requirement 
  --create_cscl_seq('SEGMENTID');
  --create_cscl_seq('SEQ_LDF_ID');

  create_cscl_seq('SEQ_ACCESSPOINT_ID','ACCESSPOINT.ACCESSPOINTID');
  create_cscl_seq('SEQ_ADDRESSPOINT_ID','ADDRESSPOINT.ADDRESSPOINTID');
  create_cscl_seq('SEQ_COMMONPLACE_ID','COMMONPLACE.PLACEID');
  -- COMPLEXACCESSPOINT is empty
  create_cscl_seq('SEQ_COMPACCESSPOINT_ID','COMPLEXACCESSPOINT.COMPLEXACCESSPOINTID');
  create_cscl_seq('SEQ_COMPLEX_ID','COMPLEX.COMPLEXID');
  create_cscl_seq('SEQ_ENTRANCEPOINT_ID','ENTRANCEPOINT.ENTRANCEPOINTID');
  create_cscl_seq('SEQ_FEATURENAMEID','FEATURENAME.FEATURENAMEID');
  create_cscl_seq('SEQ_GENERIC_ID','CENTERLINE.GENERICID');
  create_cscl_seq('SEQ_LDF_NUM','CENTERLINEHISTORY.LDF_NUM');
  create_cscl_seq('SEQ_LINK_ID','FEATURENAME.LINKID,COMMONPLACESHAVEFEATURENAMES.LINKID,RAILSTATIONSHAVEFEATURENAMES.LINKID,SUBWAYSTATIONSHAVEFEATURENAMES.LINKID');
  create_cscl_seq('SEQ_NODE_ID','NODE.NODEID');
  create_cscl_seq('SEQ_NYPD_ID','CENTERLINE.NYPDID');
  create_cscl_seq('SEQ_PHYSICAL_ID','CENTERLINE.PHYSICALID');
  create_cscl_seq('SEQ_RAIL_SUBWAY','RAIL.SEGMENTID,SUBWAY.SEGMENTID');
  create_cscl_seq('SEQ_RAILSTATION_ID','RAILSTATION.RAILSTATIONID');
  create_cscl_seq('SEQ_SEGMENT_ID','CENTERLINE.SEGMENTID,SHORELINE.SEGMENTID,NONSTREETFEATURE.SEGMENTID,RAIL.SEGMENTID,SUBWAY.SEGMENTID');
  create_cscl_seq('SEQ_STREETNAMEID','STREETNAME.STREETNAMEID');
  create_cscl_seq('SEQ_SUBWAYSTATION_ID','SUBWAYSTATION.SUBWAYSTATIONID');
  create_cscl_seq('SEQ_TRANSITBOOTH_ID','TRANSITBOOTH.TRANSITBOOTHID');
  create_cscl_seq('SEQ_TRANSITEMERGENCY_ID','TRANSITEMERGENCYEXIT.EMERGENCYEXITID');
  create_cscl_seq('SEQ_TRANSITENTRANCE_ID','TRANSITENTRANCE.ENTRANCEID');
  -- TURNRESTRICTION and TURNRESTRICTIONLIMITS are empty
  create_cscl_seq('SEQ_TURNID','TURNRESTRICTION.TURNID,TURNRESTRICTIONLIMITS.TURNID');
end;
/

drop procedure create_cscl_seq;

EXIT
