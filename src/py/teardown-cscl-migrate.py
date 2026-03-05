import os
import time
import sys
import logging
import arcpy

from resourcemanager import listmanager

def deleteitem(ptargetgdb
              ,pitem
              ,punlockkey):
    
    item = os.path.join(ptargetgdb
                       ,pitem)
    
    unlockkey = os.path.join(ptargetgdb
                            ,punlockkey)

    if  arcpy.Exists(item) \
    and arcpy.Exists(unlockkey):

        desc = arcpy.da.Describe(item)

        if desc.get("isArchived"):

            # verified that this pattern works for feature datasets too

            # disable archiving and delete the _H table
            # this may create _H1 _H2s etc due to our 
            # archive migration approach
            arcpy.management.DisableArchiving(item
                                             ,'DELETE') 

        return arcpy.Delete_management(item)
    
    elif arcpy.Exists(unlockkey):

        try:
            arcpy.management.DeleteDomain(ptargetgdb
                                         ,pitem)
            return True
        except:
            return False
    
    return False


if __name__ == '__main__':

    ptargetgdb = sys.argv[1]

    if len(sys.argv) > 2:
        plist = sys.argv[2]
    else:
        plist = 'listoflists'

    secretkey = 'UNLOCK_TEARDOWN'
    
    timestr = time.strftime("%Y%m%d-%H%M%S")

    # ..\logs\teardown-cscl-migrate-20250403-160745.log
    targetlog = os.path.join(os.environ['TARGETLOGDIR'] 
                            ,'teardown-cscl-migrate-{0}.log'.format(timestr))

    logging.basicConfig(
        level=logging.INFO,                     
        format='%(asctime)s - %(levelname)s - %(message)s', 
        filename=targetlog,                  
        filemode='w'                         
    )
    
    listbuckets = listmanager(plist).names
    
    for listbucket in listbuckets:

        gdbitems = listmanager(listbucket).names

        for gdbitem in gdbitems:
    
            logging.info("attempting to delete {0}".format(gdbitem))

            removed = deleteitem(ptargetgdb
                                ,gdbitem
                                ,secretkey)

            if not removed:

                logging.error("did not delete {0}".format(gdbitem))

            else:

                logging.info("deleted {0}".format(gdbitem))


    logging.info("teardown complete")

    sys.exit(0)
