import sys
import os
import logging
import datetime
import time

import csclelementmgr


if __name__ == "__main__":

    # listname is a list of lists
    # sub-lists can include elements that are not countable (we will ignore these)

    listname   = sys.argv[1]
    gdb2verify = sys.argv[2]
    gdbsource  = sys.argv[3]

    timestr = time.strftime("%Y%m%d-%H%M%S")
    # ..\logs\verifycounts-ditcsdv1-20250403-160745.log
    targetlog = \
        os.path.join(os.environ['TARGETLOGDIR'] 
                    ,'verifycounts-{0}-{1}.log'.format( \
                        os.path.basename(gdb2verify).split(".")[0]
                       ,timestr))

    logging.basicConfig (
        level=logging.INFO,  
        format='%(asctime)s - %(levelname)s - %(message)s',  
        handlers=[
            logging.FileHandler(targetlog),  # log messages 
            logging.StreamHandler()          # cc: screen 
        ]
    )
    logger = logging.getLogger(__name__)
    
    logger.info('starting count verification of {0} at {1}'.format(gdb2verify
                                                                  ,datetime.datetime.now()))

    listnames = csclelementmgr.Resourcelistmanager(listname).names

    badkount = 0
    
    for listname in listnames:

        objectnames = csclelementmgr.Resourcelistmanager(listname).names

        for objectname in objectnames:
            
            csclelement = csclelementmgr.CSCLElement(objectname)

            targetkount = csclelement.count(gdb2verify)

            if targetkount is not None:
                
                sourcekount = csclelement.count(gdbsource)

                if int(sourcekount) == int(targetkount):
                    logger.info('PASS:{0} | source:{1} | target:{2} | '.format(csclelement.name
                                                                              ,sourcekount
                                                                              ,targetkount))
                else:
                    badkount += 1
                    logger.error('FAIL:{0} | source:{1} | target:{2} | '.format(csclelement.name
                                                                               ,sourcekount
                                                                               ,targetkount))
    sys.exit(badkount)




