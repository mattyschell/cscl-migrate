import os
import time
import sys
import logging

import csclelementmgr
import arcpy


class Resourcelistmanager(object):

    # why is this little thing a class :0) clown?
    # todo: refactor this

    def __init__(self
                ,whichlist):

        with open(os.path.join(os.path.dirname(__file__)
                              ,'resources'
                              ,whichlist)) as l:
            
            contents = [line.strip() for line in l]

        self.names = contents  


if __name__ == '__main__':

    psrcgdb = sys.argv[1]
    ptargetgdb = sys.argv[2]

    timestr = time.strftime("%Y%m%d-%H%M%S")

    # ..\logs\loadcscl-20250403-160745.log
    targetlog = os.path.join(os.environ['TARGETLOGDIR']
                            ,'loadcscl-{0}.log'.format(timestr))

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

        gdbitems = Resourcelistmanager(listbucket).names

        for gdbitem in gdbitems:
            
            if listbucket in listisversioned:

                csclelement = csclelementmgr.CSCLElement(gdbitem)

                versioned = csclelement.version(ptargetgdb)

                if versioned == 0:

                    logging.info("skipped or failed {0}".format(gdbitem))
 

    readonlyusers = Resourcelistmanager('allreadonly').names
    editors       = Resourcelistmanager('alleditor').names

    for listbucket in listbuckets:

        gdbitems = Resourcelistmanager(listbucket).names

        for gdbitem in gdbitems:

            csclelement = csclelementmgr.CSCLElement(gdbitem)

            for readonlyuser in readonlyusers:

                granted = csclelement.grant(ptargetgdb
                                           ,'VIEW'
                                           ,readonlyuser)
                
                if granted == 0:

                    logging.info("failed to grant view on {0} to {1}".format(gdbitem
                                                                            ,readonlyuser))
                    
            for editor in editors:

                granted = csclelement.grant(ptargetgdb
                                           ,'EDIT'
                                           ,editor)
                
                if granted == 0:

                    logging.info("failed to grant edit on {0} to {1}".format(gdbitem
                                                                            ,readonlyuser))


    logging.info("load complete or load complete?")

    sys.exit(0)