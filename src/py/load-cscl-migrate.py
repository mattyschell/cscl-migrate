import os
import time
import sys
import logging
import arcpy

# py 3 here
# file geodatabase -> enterprise geodatabase

class Resourcelistmanager(object):

    def __init__(self
                ,whichlist):

        with open(os.path.join(os.path.dirname(__file__)
                 ,'resources', whichlist)) as l:
            
            contents = [line.strip() for line in l]

        self.names = contents  

def copypaste(psrcgdb
             ,psrcitem
             ,ptargetgdb):

    retval = 0

    srcitem = os.path.join(psrcgdb, psrcitem)
    targetitem = os.path.join(ptargetgdb, psrcitem)

    logging.debug("srcitem {0}".format(srcitem))
    logging.debug("targetitem {0}".format(targetitem))

    if arcpy.Exists(targetitem):

        logging.debug('skipping already existing {0}'.format(targetitem))
        return retval
    
    else:

        try:

            arcpy.management.Copy(srcitem, targetitem)
            
            if arcpy.Exists(targetitem):

                logging.info(f"Successfully copied {srcitem} to {targetitem}")
                return 1
            
            else:

                logging.error(f"Copy operation failed for {srcitem}")
                return 0

        except arcpy.ExecuteError:

            logging.error(f"ArcPy error: {arcpy.GetMessages(2)}")
            return 0
        
        except Exception as e:

            logging.error(f"Unexpected error: {str(e)}")
            return 0

if __name__ == '__main__':

    psrcgdb = sys.argv[1]
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

    listbuckets = Resourcelistmanager('listoflists').names
    logging.debug('listbuckets {0}'.format(listbuckets))

    listisversioned = Resourcelistmanager('listofversionedlists').names
    logging.debug('listisversioned {0}'.format(listisversioned))

    for listbucket in listbuckets:

        logging.debug('listbucket {0}'.format(listbucket))

        gdbitems = Resourcelistmanager(listbucket).names

        logging.debug('gdbitems {0}'.format(gdbitems))

        for gdbitem in gdbitems:

            logging.info("loading {0}".format(gdbitem))
            loaded = copypaste(psrcgdb, gdbitem, ptargetgdb)

            if loaded == 0:

                logging.info("skipped or failed {0}".format(gdbitem))

            elif listbucket in listisversioned:

                logging.info('versioning {0}'.format(listbucket))
                
                arcpy.management.RegisterAsVersioned(gdbitem)      

    logging.info("load complete or load complete?")

    sys.exit(0)
