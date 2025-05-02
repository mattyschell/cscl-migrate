import os
import time
import sys
import logging
import arcpy

# py 3 here
# file geodatabase -> enterprise geodatabase
# basically the same as py27-extract-cscl-migrate.py
# todo: consider refactoring into one 

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

    psrcgdb    = sys.argv[1]
    ptargetgdb = sys.argv[2]
    
    timestr = time.strftime("%Y%m%d-%H%M%S")

    # ..\logs\load-cscl-migrate-20250403-160745.log
    targetlog = os.path.join(os.environ['TARGETLOGDIR'] 
                            ,'load-cscl-migrate-{0}.log'.format(timestr))

    logging.basicConfig(
        level=logging.DEBUG,                     
        format='%(asctime)s - %(levelname)s - %(message)s', 
        filename=targetlog,                  
        filemode='w'                         
    )
    
    srcbucket = 'CSCL'
    logging.info("loading {0}".format(srcbucket))

    loaded = copypaste(psrcgdb
                      ,srcbucket
                      ,ptargetgdb)
            
    if loaded == 0:

        logging.info("skipped {0}".format(srcbucket))


    srcbucket = 'featureclasses'   
    srcitems = Resourcelistmanager(srcbucket)

    for srcitem in srcitems.names:

        logging.info("loading {0}".format(srcitem))
        
        loaded = copypaste(psrcgdb
                          ,srcitem
                          ,ptargetgdb)
            
        if loaded == 0:

            logging.info("skipped {0}".format(srcitem))


    srcbucket = 'tables'   
    srcitems  = Resourcelistmanager(srcbucket)

    for srcitem in srcitems.names:

        logging.info("loading {0}".format(srcitem))
        
        loaded = copypaste(psrcgdb
                          ,srcitem
                          ,ptargetgdb)
            
        if loaded == 0:

            logging.info("skipped {0}".format(srcitem))

    srcbucket = 'relationshipclasses'   
    srcitems  = Resourcelistmanager(srcbucket)

    for srcitem in srcitems.names:

        logging.info("loading {0}".format(srcitem))
        
        loaded = copypaste(psrcgdb
                          ,srcitem
                          ,ptargetgdb)
            
        if loaded == 0:

            logging.info("skipped {0}".format(srcitem))

    srcbucket = 'publicsafetyfeatureclasses'   
    srcitems  = Resourcelistmanager(srcbucket)

    for srcitem in srcitems.names:

        logging.info("loading {0}".format(srcitem))
        
        loaded = copypaste(psrcgdb
                          ,srcitem
                          ,ptargetgdb)
            
        if loaded == 0:

            logging.info("skipped {0}".format(srcitem))

    logging.info("end")

    sys.exit(0)
