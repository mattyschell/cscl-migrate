import sys
import os
import logging
import datetime
import time

import arcpy
import csclelementmgr
import dataownermanager


if __name__ == "__main__":

    # this must be a list of lists
    # if we only want to check tables for example
    # make a list with one element: alltable
    # case is sensitive

    listname   = sys.argv[1]
    gdb2verify = sys.argv[2]

    arcpy.env.workspace = gdb2verify

    timestr = time.strftime("%Y%m%d-%H%M%S")
    # ..\logs\verifycatalog-ditcsdv1-20250403-160745.log
    targetlog = \
        os.path.join(os.environ['TARGETLOGDIR'] 
                    ,'verifycatalog-{0}-{1}.log'.format( \
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
    
    logger.info('starting catalog verification of {0} at {1}'.format(gdb2verify
                                                                    ,datetime.datetime.now()))
    try:
        desc = arcpy.Describe(arcpy.env.workspace)
    except:
        logger.error("Cant validate this: {0} Check paths and sde file names".format(gdb2verify))
        sys.exit(1)

    gdb = dataownermanager.DataOwner(arcpy.env.workspace)

    # what can this user see
    existingobjects = gdb.getallobjects()

    listnames = csclelementmgr.Resourcelistmanager(listname).names

    expectedobjects = []
    
    for listname in listnames:

        objectnames = csclelementmgr.Resourcelistmanager(listname).names

        # must loop again due to deceitful feature datasets
        # we may get duplicates added to our lists when there are overlaps
        # this is OK. we dedupe with set(expectedobjects) below 

        for objectname in objectnames:

            csclelement = csclelementmgr.CSCLElement(objectname)

            if csclelement.getgdbtype() == 'featuredataset':

                deepobjectnames = csclelementmgr.Resourcelistmanager(csclelement.name).names
                expectedobjects = expectedobjects + deepobjectnames

            else:

                expectedobjects.append(objectname) 

    # we dont check the other direction (for now)
    # extra objects in the database are allowed
    # missing objects in the database -> we messed up

    expectednotexisting = set(expectedobjects).difference(set(existingobjects))

    if len(expectednotexisting) == 0:
        logger.info('Verified {0} geodatabase objects'.format(len(expectedobjects)))
        logger.info('PASS: completed qa of {0} at at {1}'.format(gdb2verify
                                                                ,datetime.datetime.now()))
        sys.exit(0)
    else:
        for missing in expectednotexisting:
            logger.warning('{0} is missing!'.format(missing))
        sys.exit(1)



