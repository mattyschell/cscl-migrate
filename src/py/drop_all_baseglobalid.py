import os
import time
import argparse
import logging

import csclelementmgr
from resourcemanager import listmanager


def main():

    parser = argparse.ArgumentParser(
        description="Drop BASEGLOBALID from base tables/featureclasses/relationshipclasses"
    )
    parser.add_argument("targetgdb", help="Geodatabase")
    args = parser.parse_args()

    timestr = time.strftime("%Y%m%d-%H%M%S")

    # ..\logs\drop-all-baseglobalid-20250403-160745.log
    targetlog = os.path.join(os.environ['TARGETLOGDIR']
                            ,'drop-all-baseglobalid-{0}.log'.format(timestr))

    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        filename=targetlog,
        filemode='w'
    )

    badkount = 0

    # same universe globalid_manager.preserve_globalid populated
    for listname in listmanager('listofbasetablelists').names:

        for objectname in listmanager(listname).names:

            csclelement = csclelementmgr.CSCLElement(objectname)

            if not csclelement.exists(args.targetgdb):
                logging.info("skipped {0} because it doesnt exist on the target".format(csclelement.name))
                continue

            try:
                csclelement.drop_baseglobalid(args.targetgdb)
                logging.info("dropped BASEGLOBALID from {0}".format(csclelement.name))
            except Exception as ex:
                badkount += 1
                logging.error("failed to drop BASEGLOBALID from {0}: {1}".format(csclelement.name, ex))

    if badkount > 0:
        logging.error("failed to drop BASEGLOBALID from {0} datasets".format(badkount))

    return badkount


if __name__ == "__main__":

    import sys
    sys.exit(main())
