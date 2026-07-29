import sys
import os
import logging
import datetime
import time

import arcpy
from resourcemanager import listmanager


if __name__ == "__main__":

    # this must be a list of lists
    # if we only want to check domains for example
    # make a list with one element: alldomain
    # case is sensitive

    listname    = sys.argv[1]
    gdb2verify  = sys.argv[2]
    targetschema = sys.argv[3]  # schema owner to verify domains against

    arcpy.env.workspace = gdb2verify

    timestr = time.strftime("%Y%m%d-%H%M%S")
    # ..\logs\verifydomain-ditcsdv1-20250403-160745.log
    targetlog = \
        os.path.join(os.environ['TARGETLOGDIR'] 
                    ,'verifydomain-{0}-{1}.log'.format( \
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
    
    logger.info('starting domain verification of {0} at {1}'.format(gdb2verify
                                                                   ,datetime.datetime.now()))
    try:
        desc = arcpy.Describe(arcpy.env.workspace)
    except:
        logger.error("Cant validate this: {0} Check paths and sde file names".format(gdb2verify))
        sys.exit(1)

    # get all domains in the geodatabase
    existingdomains = {}
    for domain in arcpy.da.ListDomains(arcpy.env.workspace):
        existingdomains[domain.name] = domain.owner

    # get expected domains from resource file
    listnames = listmanager(listname).names

    expecteddomains = []
    
    for domainname in listnames:
        expecteddomains.append(domainname)

    # domains not found in geodatabase
    expectednotexisting = set(expecteddomains).difference(set(existingdomains.keys()))
    
    # domains with wrong owner
    wrongowner = []
    for domainname in expecteddomains:
        if domainname in existingdomains:
            if existingdomains[domainname].upper() != targetschema.upper():
                wrongowner.append((domainname, existingdomains[domainname]))

    if len(expectednotexisting) == 0 and len(wrongowner) == 0:
        logger.info('Verified {0} domains'.format(len(expecteddomains)))
        logger.info('PASS: completed qa of {0} at {1}'.format(gdb2verify
                                                             ,datetime.datetime.now()))
        sys.exit(0)
    else:
        for missing in expectednotexisting:
            logger.warning('{0} domain is missing!'.format(missing))
        for domainname, owner in wrongowner:
            logger.warning('{0} domain exists but is owned by {1}, not {2}'.format(
                domainname, owner, targetschema))
        sys.exit(len(expectednotexisting) + len(wrongowner))
