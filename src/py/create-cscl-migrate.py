import os
import time
import sys
import logging
from filegeodatabasemanager import localgdb 
 

if __name__ == '__main__':

    pworkdir = sys.argv[1]
    
    timestr = time.strftime("%Y%m%d-%H%M%S")

    # they say he's doing the most

    # ..\logs\create-cscl-migrate-20250403-160745.log
    targetlog = os.path.join(os.environ['TARGETLOGDIR'] 
                            ,'create-cscl-migrate-{0}.log'.format(timestr))

    logging.basicConfig (
        level=logging.DEBUG,  
        format='%(asctime)s - %(levelname)s - %(message)s',  
        handlers=[
            logging.FileHandler(targetlog),  # log messages 
            logging.StreamHandler()          # cc: screen 
        ]
    )

    logger = logging.getLogger(__name__)

    emptygdb = localgdb(os.path.join(pworkdir
                                    ,'cscl-migrate.gdb'))
    
    emptygdb.clean()

    emptygdb.create()

    logger.info("Created empty {0} ".format(emptygdb.gdb))

    sys.exit(0)
