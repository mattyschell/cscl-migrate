import os
import time
import sys
import logging
import arcpy
from filegeodatabasemanager import localgdb 
# crossing the py2 py3 chasm
import csclelementmgr

# PY27 
# source geodatabase has class extensions
# it can only be read by classic arcmap

def copypaste(psrcgdb
             ,pitempath
             ,ptargetgdb):
    
    # archive class stickcopy should not have stickies, right?
    # right???
    # so we will not check for pre-existence here
    # pre-existence would imply stickiness or an error

    retval = 0

    srcitem = os.path.join(psrcgdb
                          ,pitempath)

    targetitem = os.path.join(ptargetgdb
                             ,pitempath)
        
    try:
        
        arcpy.management.Copy(srcitem
                             ,targetitem)

        retval = 1

    except arcpy.ExecuteError:
        logging.error("failure copying {0} to {1}".format(srcitem,targetitem))
        logging.error("arcpy.management.Copy returned {0}".format(arcpy.GetMessages(2)))

    except Exception as e:
        logging.error("failure copying {0} to {1}".format(srcitem,targetitem))
        logging.error("unexpected error {0}".format(e))
        
    return retval


if __name__ == '__main__':

    psrcgdb    = sys.argv[1]
    ptargetgdb = sys.argv[2]
    plistname  = sys.argv[3]
    
    timestr = time.strftime("%Y%m%d-%H%M%S")

    # ..\logs\py27-migrate-archive-20250403-160745.log
    targetlog = os.path.join(os.environ['TARGETLOGDIR'] 
                            ,'py27-migrate-archive-{0}.log'.format(timestr))

    logging.basicConfig(
        level=logging.INFO,                     
        format='%(asctime)s - %(levelname)s - %(message)s', 
        filename=targetlog,                  
        filemode='w'                         
    )

    # src/py/resources/allarchiving or similar 
    archiveclassnames = csclelementmgr.Resourcelistmanager(plistname).names

    logging.info("migrating objects in list {0}".format(plistname))

    for archiveclassname in archiveclassnames:

        archiveobject = csclelementmgr.CSCLElement(archiveclassname)

        migrated = 0

        if archiveobject.exists(psrcgdb) and not archiveobject.exists(ptargetgdb):

            logging.info("migrating archive class {0}".format(archiveobject.name))

            migrated = copypaste(psrcgdb
                                ,archiveobject.itempath
                                ,ptargetgdb)
            
            if migrated == 0:

                logging.info("failed to migrate {0}".format(archiveobject.name))
            
            else:

                logging.info("successfully migrated {0}".format(archiveobject.name))

        else:

            logging.error("skipped {0} because it exists on target or doesnt exist on source".format(archiveobject.name))

    logging.info("done migrating all archive classes in {0}".format(plistname))

    sys.exit(0)

