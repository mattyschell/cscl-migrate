import os
import time
import sys
import logging
import argparse
import arcpy

import csclelementmgr
from resourcemanager import listmanager


def main():

    parser = argparse.ArgumentParser(description="QA a child CSCL dataset")

    parser.add_argument("targetgdb", help="Dataset name in cscl")
    args = parser.parse_args()

    timestr = time.strftime("%Y%m%d-%H%M%S")

    # ..\logs\finalizeloadcscl-20250403-160745.log
    targetlog = os.path.join(os.environ['TARGETLOGDIR']
                            ,'rerungrants-{0}.log'.format(timestr))

    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s - %(levelname)s - %(message)s',
        filename=targetlog,
        filemode='w'
    )

    listbuckets   = listmanager('listoflists')
    readonlyusers = listmanager('allreadonly')
    editors       = listmanager('alleditor')

    for listbucket in listbuckets.names:

        gdbitems = listmanager(listbucket)

        for gdbitem in gdbitems.names:

            csclelement = csclelementmgr.CSCLElement(gdbitem)

            for readonlyuser in readonlyusers.names:

                granted, gex = csclelement.grant(args.targetgdb
                                                ,'VIEW'
                                                ,readonlyuser)
                
                if granted == 1:

                    logging.info(
                        "failed to grant view on {0} to {1} got {2}".format(
                            gdbitem
                           ,readonlyuser
                           ,gex))
                
                else:

                    logging.info(
                        "granted view on {0} to {1}".format(gdbitem
                                                           ,readonlyuser))
                
                    
            for editor in editors.names:

                granted, gex = csclelement.grant(args.targetgdb
                                                ,'EDIT'
                                                ,editor)
                
                if granted == 1:

                    logging.info(
                        "failed to grant edit on {0} to {1} got {2}".format(
                            gdbitem
                           ,editor
                           ,gex))
                else:

                    logging.info("granted edit on {0} to {1}".format(gdbitem
                                                                    ,editor))

    logging.info(
        "{0} grants complete. Spread love. Its the Brooklyn way".format(args.targetgdb))

    sys.exit(0)


if __name__ == "__main__":
    main()