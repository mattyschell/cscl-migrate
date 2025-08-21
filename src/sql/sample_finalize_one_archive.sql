-- reminder: do this as CSCL on source first
--    call sde.nyc_archive_utils.reveal_history('SCHOOLDISTRICT');
-- then copy/paste
-- now finalize
call owner_archive_utils.update_base_ids('SCHOOLDISTRICT','SCHOOLDISTRICT_H');
-- check ENV_register_all_archiving.sql for exact values
call sde.nyc_archive_utils.register_archiving('SCHOOLDISTRICT' ,'SCHOOLDISTRICT_H' ,1273245334);
call sde.nyc_archive_utils.conceal_history('SCHOOLDISTRICT');
-- then back to CSCL on source
--    call sde.nyc_archive_utils.conceal_history('SCHOOLDISTRICT');
