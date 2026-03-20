import os
import time
import sys
import logging
import argparse

import csclelementmgr
from resourcemanager import listmanager


def main():

    parser = argparse.ArgumentParser(description="Apply grants to CSCL data")

    parser.add_argument("targetgdb", help="Geodatabase")
    args = parser.parse_args()

    timestr = time.strftime("%Y%m%d-%H%M%S")

    # ..\logs\finalizeloadcscl-20250403-160745.log
    targetlog = os.path.join(os.environ['TARGETLOGDIR']
                            ,'applygrants-{0}.log'.format(timestr))

    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s - %(levelname)s - %(message)s',
        filename=targetlog,
        filemode='w'
    )

    listbuckets   = listmanager('listoflists')
    readonlyusers = listmanager('allreadonly')
    editors       = listmanager('alleditor')

    badkount = 0

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

                    badkount+=1
                
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

                    badkount+=1

                else:

                    logging.info("granted edit on {0} to {1}".format(gdbitem
                                                                    ,editor))

    if badkount == 0:

        logging.info(
            "Success applying grants on {0}. Spread love. Its the Brooklyn way".format(
                args.targetgdb))

    else:

        logging.info(
            "Failed to apply all grants on {0}. Review {1}".format(
                args.targetgdb
               ,targetlog))

    sys.exit(badkount)


if __name__ == "__main__":
    main()