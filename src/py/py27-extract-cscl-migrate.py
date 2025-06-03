import os
import time
import sys
import logging
import arcpy
from filegeodatabasemanager import localgdb 


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

    # print("targetitem {0}".format(targetitem))

    if arcpy.Exists(targetitem):
        
        return retval
    
    else:
        
        arcpy.management.Copy(srcitem
                             ,targetitem)



if __name__ == '__main__':

    pworkdir = sys.argv[1]
    psrcgdb  = sys.argv[2]
    
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

    
    srcbucket = 'CSCL'
    logging.info("extracting {0}".format(srcbucket))

    extracted = copypaste(psrcgdb
                         ,srcbucket
                         ,targetgdb.gdb)
            
    if extracted == 0:

        logging.info("failed {0}".format(srcbucket))


    srcbucket = 'allfeatureclass'   
    srcitems = Resourcelistmanager(srcbucket)

    for srcitem in srcitems.names:

        logging.info("extracting {0}".format(srcitem))
        
        extracted = copypaste(psrcgdb
                             ,srcitem
                             ,targetgdb.gdb)
            
        if extracted == 0:

            logging.info("skipped {0}".format(srcitem))


    srcbucket = 'alltable'   
    srcitems  = Resourcelistmanager(srcbucket)

    for srcitem in srcitems.names:

        logging.info("extracting {0}".format(srcitem))
        
        extracted = copypaste(psrcgdb
                             ,srcitem
                             ,targetgdb.gdb)
            
        if extracted == 0:

            logging.info("skipped {0}".format(srcitem))

    srcbucket = 'allrelationshipclass'   
    srcitems  = Resourcelistmanager(srcbucket)

    for srcitem in srcitems.names:

        logging.info("extracting {0}".format(srcitem))
        
        extracted = copypaste(psrcgdb
                             ,srcitem
                             ,targetgdb.gdb)
            
        if extracted == 0:

            logging.info("skipped {0}".format(srcitem))

    logging.info("end")

    sys.exit(0)
