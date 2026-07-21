call owner_archive_utils.update_base_ids('HURRICANEEVACUATIONZONE'
                                        ,'HURRICANEEVACUATIONZONE_H');
-- check ENV_register_all_archiving.sql for exact values
call sde.nyc_archive_utils.register_archiving('HURRICANEEVACUATIONZONE'
                                             ,'HURRICANEEVACUATIONZONE_H' 
                                             ,1409932765);
call sde.nyc_archive_utils.conceal_history('HURRICANEEVACUATIONZONE');