import sys
import os
import logging
import datetime
import time

import csclelementmgr
from resourcemanager import listmanager

def setup_logging(gdb2verify):

    timestr = time.strftime("%Y%m%d-%H%M%S")
    targetlog = os.path.join(
        os.environ['TARGETLOGDIR'],
        'verifycounts-{0}-{1}.log'.format(
            os.path.basename(gdb2verify).split(".")[0],
            timestr
        )
    )

    # Avoid duplicate handlers if called multiple times
    logger = logging.getLogger(__name__)
    if logger.handlers:
        return logger

    if sys.version_info >= (3, 3):
            # Python 3.3+ path
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(targetlog),
                logging.StreamHandler()
            ]
        )
        return logging.getLogger(__name__)

    # Python 2.7 fallback
    logger.setLevel(logging.INFO)
    fh = logging.FileHandler(targetlog)
    sh = logging.StreamHandler()
    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    fh.setFormatter(formatter)
    sh.setFormatter(formatter)
    logger.addHandler(fh)
    logger.addHandler(sh)

    return logger


if __name__ == "__main__":

    # listname is a list of lists
    # sub-lists can include elements that are not countable (we will ignore these)

    listname   = sys.argv[1]
    gdb2verify = sys.argv[2]
    gdbsource  = sys.argv[3]

    logger = setup_logging(gdb2verify)
    
    logger.info('starting count verification of {0} at {1}'.format(gdb2verify
                                                                  ,datetime.datetime.now()))

    listnames = listmanager(listname).names

    badkount = 0
    
    for listname in listnames:

        objectnames = listmanager(listname).names

        for objectname in objectnames:

            csclelement = csclelementmgr.CSCLElement(objectname)

            try:
                targetkount = csclelement.count(gdb2verify)
                
            except Exception as ex:
                targetkount = 0
                logging.error('Count failed for {0} in {1}: {2}'.format(
                     objectname
                    ,gdb2verify
                    ,ex)
                )

            try:
                sourcekount = csclelement.count(gdbsource)
            except Exception as ex:
                sourcekount = 0
                logging.error('Count failed for {0} in {1}: {2}'.format(
                     objectname
                    ,gdbsource
                    ,ex)
                )

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




