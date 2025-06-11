import os
import time
import sys
import logging
import arcpy
from filegeodatabasemanager import localgdb 
# pressing our luck here. crossing the py2 py3 chasm
import csclelementmgr


# PY27 
# source geodatabase has class extensions
# it can only be read by classic arcmap

class Resourcelistmanager(object):

    def __init__(self,
                 whichlist):

        with open(os.path.join(os.path.dirname(__file__)
                              ,'resources'
                              ,whichlist)) as l:

            contents = [line.strip() for line in l]

        self.names = contents  

def copypaste(psrcgdb
             ,psrcitem
             ,ptargetgdb):
    
    retval = 0

    srcitem = os.path.join(psrcgdb
                          ,psrcitem)

    targetitem = os.path.join(ptargetgdb
                             ,psrcitem)

    if arcpy.Exists(targetitem):
        
        return retval
    
    else:
        
        arcpy.management.Copy(srcitem
                             ,targetitem)


if __name__ == '__main__':

    pworkdir  = sys.argv[1]
    psrcgdb   = sys.argv[2]
    plistname = sys.argv[3]
    
    timestr = time.strftime("%Y%m%d-%H%M%S")

    # ..\logs\extract-cscl-migrate-20250403-160745.log
    targetlog = os.path.join(os.environ['TARGETLOGDIR'] 
                            ,'extract-cscl-migrate-{0}.log'.format(timestr))

    logging.basicConfig(
        level=logging.DEBUG,                     
        format='%(asctime)s - %(levelname)s - %(message)s', 
        filename=targetlog,                  
        filemode='w'                         
    )

    targetgdb = localgdb(os.path.join(pworkdir
                                    ,'cscl-migrate.gdb'))

    listnames = csclelementmgr.Resourcelistmanager(plistname).names

    # allfeaturedataset CSCL should be first in the list of lists

    for listname in listnames:

        logging.info("extracting objects in list {0}".format(listname))

        objectnames = csclelementmgr.Resourcelistmanager(listname).names

        for objectname in objectnames:

            logging.info("extracting object {0}".format(objectname))

            extracted = copypaste(psrcgdb
                                 ,objectname
                                 ,targetgdb.gdb)
            
            if extracted == 0:

                logging.info("skipped {0}".format(objectname))


    logging.info("finished extracting all lists from {0}".format(plistname))

    sys.exit(0)
