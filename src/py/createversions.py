import os
import time
import sys
import logging
import argparse
import arcpy

from resourcemanager import listmanager
import version_manager


def main():

    parser = argparse.ArgumentParser(description="Create CSCL versions")

    parser.add_argument("targetgdb", help="Geodatabase")
    parser.add_argument("--schema-name", default="CSCL",
                        help="Expected calling schema/user (default: CSCL)")
    args = parser.parse_args()

    timestr = time.strftime("%Y%m%d-%H%M%S")

    # ..\logs\createversions-20250403-160745.log
    targetlog = os.path.join(os.environ['TARGETLOGDIR']
                            ,'createversions-{0}.log'.format(timestr))

    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s - %(levelname)s - %(message)s',
        filename=targetlog,
        filemode='w'
    )

    try:
        calling_schema = arcpy.Describe(args.targetgdb).connectionProperties.user.upper()
    except Exception as ex:
        logging.error('Unable to determine calling schema for {0}: {1}'.format(
            args.targetgdb,
            ex
        ))
        sys.exit(1)

    expected_schema = args.schema_name.upper()

    if calling_schema != expected_schema:
        # https://github.com/mattyschell/cscl-migrate/issues/63
        logging.info('Skipping createversions because schema is {0}, not expected {1}'.format(
            calling_schema,
            expected_schema
        ))
        sys.exit(0)

    badkount = 0
    # these must be ordered top to bottom
    # there will be no checking or fancy footwork here
    versions   = listmanager('allversions')

    for version in versions.names:

        # versionname parent.versionname Access
        # ex
        # EDITVERSION XYZ.DAILYEDITS Public
        # Do not fully qualify versionname.  The creator is the owner
        version_info = {
            "name": version.split()[0],
            "parent": version.split()[1],
            "access": version.split()[2]
        }

        version = version_manager.Version(args.targetgdb
                                         ,version_info['name']
                                         ,version_info['parent']
                                         ,version_info['access'])
        
        if version.exists():

            logging.info('Skipping version {0}. Already exists'.format(
                version_info['name']))

        else:

            logging.info('Creating version {0}'.format(version_info['name']))
            try:
                version.create()
            except Exception as ex:
                badkount += 1
                logging.error('Creating version {0} failed with {1}'.format(
                     version_info['name']
                    ,ex)
                )
                sys.exit(badkount)

            if version.exists():

                logging.info('Success creating version {0}'.format(
                    version_info['name']))

            else:

                badkount += 1
                logging.error('Failed to create version {0}'.format(
                    version_info['name']))        

    if badkount == 0:
        logging.info('Completed createversions')

    sys.exit(badkount)


if __name__ == "__main__":
    main()