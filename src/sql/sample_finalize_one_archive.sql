-- reminder: (these steps are spelled out in README.md)
-- you should have done this as CSCL on the source first
--    call sde.nyc_archive_utils.reveal_history('HURRICANEEVACUATIONZONE');
-- then copy/paste
-- now finalize
call owner_archive_utils.update_base_ids('HURRICANEEVACUATIONZONE','HURRICANEEVACUATIONZONE_H');
-- check ENV_register_all_archiving.sql for exact values
call sde.nyc_archive_utils.register_archiving('HURRICANEEVACUATIONZONE' ,'HURRICANEEVACUATIONZONE_H' ,1273245334);
call sde.nyc_archive_utils.conceal_history('HURRICANEEVACUATIONZONE');
-- then back to CSCL on the source
--    call sde.nyc_archive_utils.conceal_history('HURRICANEEVACUATIONZONE');
