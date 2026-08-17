WHENEVER SQLERROR EXIT SQL.SQLCODE;

CREATE OR REPLACE PROCEDURE drop_cscl_seq_if_exists (
    p_sequence_name IN VARCHAR2
) AS
BEGIN
    EXECUTE IMMEDIATE 'drop sequence "' || UPPER(p_sequence_name) || '"';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2289 THEN
            NULL; -- ORA-02289: sequence does not exist
        ELSE
            RAISE;
        END IF;
END;
/

begin
  --these are unused? We will not carry them unless required
  --drop_cscl_seq_if_exists('SEGMENTID');
  --drop_cscl_seq_if_exists('SEQ_LDF_ID');
  drop_cscl_seq_if_exists('SEQ_ACCESSPOINT_ID');
  drop_cscl_seq_if_exists('SEQ_ADDRESSPOINT_ID');
  drop_cscl_seq_if_exists('SEQ_COMMONPLACE_ID');
  drop_cscl_seq_if_exists('SEQ_COMPACCESSPOINT_ID');
  drop_cscl_seq_if_exists('SEQ_COMPLEX_ID');
  drop_cscl_seq_if_exists('SEQ_ENTRANCEPOINT_ID');
  drop_cscl_seq_if_exists('SEQ_FEATURENAMEID');
  drop_cscl_seq_if_exists('SEQ_GENERIC_ID');
  drop_cscl_seq_if_exists('SEQ_LDF_NUM');
  drop_cscl_seq_if_exists('SEQ_LINK_ID');
  drop_cscl_seq_if_exists('SEQ_NODE_ID');
  drop_cscl_seq_if_exists('SEQ_NYPD_ID');
  drop_cscl_seq_if_exists('SEQ_PHYSICAL_ID');
  drop_cscl_seq_if_exists('SEQ_RAIL_SUBWAY');
  drop_cscl_seq_if_exists('SEQ_RAILSTATION_ID');
  drop_cscl_seq_if_exists('SEQ_SEGMENT_ID');
  drop_cscl_seq_if_exists('SEQ_STREETNAMEID');
  drop_cscl_seq_if_exists('SEQ_SUBWAYSTATION_ID');
  drop_cscl_seq_if_exists('SEQ_TRANSITBOOTH_ID');
  drop_cscl_seq_if_exists('SEQ_TRANSITEMERGENCY_ID');
  drop_cscl_seq_if_exists('SEQ_TRANSITENTRANCE_ID');
  drop_cscl_seq_if_exists('SEQ_TURNID');
end;
/

drop procedure drop_cscl_seq_if_exists;

EXIT
