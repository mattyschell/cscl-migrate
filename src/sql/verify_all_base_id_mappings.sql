-- Run as the data owner on the target.
-- Fails if a real base GLOBALID maps to more than one _H.OBJECTID.
-- helper for #2 here: https://github.com/mattyschell/cscl-migrate/issues/71
-- "Validate that every real base GLOBALID maps to exactly 1 or 0 _H.OBJECTID."

DECLARE
    psql             VARCHAR2(4000);
    zero_globalid    VARCHAR2(38) := '{00000000-0000-0000-0000-000000000000}';
    mismatch_count   NUMBER;
    badcount         NUMBER := 0;
BEGIN
    FOR rec IN (
        SELECT
            r.table_name AS base_table
           ,r.table_name || '_H' AS h_table
        FROM
            sde.table_registry r
        WHERE
            r.owner = SYS_CONTEXT('USERENV', 'CURRENT_USER')
            AND r.table_name NOT LIKE '%\_H' ESCAPE '\'
        ORDER BY
            r.table_name
    )
    LOOP
        psql := 'SELECT COUNT(*) '
             || 'FROM ( '
             || '    SELECT base.globalid '
             || '    FROM ' || rec.base_table || ' base '
             || '    LEFT JOIN ' || rec.h_table || ' hist '
             || '      ON hist.globalid = base.globalid '
             || '     AND hist.globalid IS NOT NULL '
             || '     AND hist.globalid <> :p_zero_globalid '
             || '    WHERE base.globalid IS NOT NULL '
             || '      AND base.globalid <> :p_zero_globalid '
             || '    GROUP BY base.globalid '
             || '    HAVING COUNT(DISTINCT hist.objectid) > 1 '
             || ')';

        BEGIN
            EXECUTE IMMEDIATE psql
                INTO mismatch_count
                USING zero_globalid, zero_globalid;

            IF mismatch_count = 0 THEN
                DBMS_OUTPUT.PUT_LINE('PASS:' || rec.base_table
                                    || ' | archive:' || rec.h_table);
            ELSE
                badcount := badcount + 1;
                DBMS_OUTPUT.PUT_LINE('FAIL:' || rec.base_table
                                    || ' | archive:' || rec.h_table
                                    || ' | GLOBALIDs with multiple OBJECTIDs:' || mismatch_count);
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                badcount := badcount + 1;
                DBMS_OUTPUT.PUT_LINE('ERROR:' || rec.base_table
                                    || ' | archive:' || rec.h_table
                                    || ' | ' || SQLERRM);
        END;
    END LOOP;

    IF badcount > 0 THEN
        RAISE_APPLICATION_ERROR(-20004
            ,badcount || ' base/archive mappings failed GLOBALID to OBJECTID validation');
    END IF;
END;
