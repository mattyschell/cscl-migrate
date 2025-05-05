import os
import time
import sys
import logging
import arcpy


class Resourcelistmanager(object):

    def __init__(self,
                 whichlist):

        with open(os.path.join(os.path.dirname(__file__)
                              ,'resources'
                              ,whichlist)) as l:

            contents = [line.strip() for line in l]

        self.names = contents  

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
            arcpy.management.DisableArchiving(item
                                             ,'DELETE') 

        return arcpy.Delete_management(item)


if __name__ == '__main__':

    ptargetgdb = sys.argv[1]

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
    
    listbuckets = ['featuredatasets'
                  ,'featureclasses'
                  ,'tables'
                  ,'relationshipclasses'
                  ,'publicsafetyfeatureclasses']
    
    for listbucket in listbuckets:

        gdbitems = Resourcelistmanager(listbucket).names

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
