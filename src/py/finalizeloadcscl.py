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

def create_topology(gdb
                   ,topology_name = 'CSCL_Topology'):
    
    # this section started with a standalone script by mrahman-doitt
    # he also advises:
    # "but I recommend using the Load Topology Rules option in ArcMap or ArcGIS 
    # "Pro to load the rules (see attached file). This approach helps minimize 
    # "the risk of mistakes when defining rules in code."
    # I dont understand what he means

    logger = logging.getLogger()

    topology = csclelementmgr.CSCLElement(topology_name)
    featuredataset = csclelementmgr.CSCLElement(topology.featuredataset)

    dataset_path = os.path.join(gdb
                               ,featuredataset.itempath)

    logger.info('Creating topology {0} in {1}'.format(topology.name
                                                     ,os.path.join(gdb
                                                                  ,featuredataset.itempath)
                                                    ))

    arcpy.management.CreateTopology(os.path.join(gdb
                                                ,featuredataset.itempath)
                                   ,topology.name
                                   ,topology.tolerance)
    

    topology_path = os.path.join(gdb
                                ,topology.itempath)
    
    featureclasses = ['Centerline'
                     ,'MilePost'
                     ,'ReferenceMarker'
                     ,'Node']

    for featureclass in featureclasses:

        logger.info('Adding featureclass {0} to topology'.format(featureclass))
                                 
        arcpy.management.AddFeatureClassToTopology(topology_path
                                                  ,os.path.join(dataset_path,
                                                                featureclass)
                                                  ,1
                                                  ,1)

    logger.info('Adding rule 1 to {0}'.format(topology_path))
    arcpy.management.AddRuleToTopology(topology_path
                                      ,"Must Be Covered By (Point-Line)"
                                      ,os.path.join(dataset_path, 'MilePost')
                                      ,""
                                      ,os.path.join(dataset_path, 'Centerline')
                                      ,"")
    
    logger.info('Adding rule 2 to {0}'.format(topology_path))
    arcpy.management.AddRuleToTopology(topology_path
                                      ,"Must Be Covered By (Point-Line)"
                                      ,os.path.join(dataset_path, 'ReferenceMarker')
                                      ,""
                                      ,os.path.join(dataset_path, 'Centerline')
                                      ,"")

    logger.info('Adding rule 3 to {0}'.format(topology_path))
    arcpy.management.AddRuleToTopology(topology_path
                                      ,"Must Be Covered By Endpoint Of (Point-Line)"
                                      ,os.path.join(dataset_path, 'Node')
                                      ,""
                                      ,os.path.join(dataset_path, 'Centerline')
                                      ,"")
    
    logger.info('Adding rule 4 to {0}'.format(topology_path))
    arcpy.management.AddRuleToTopology(topology_path
                                      ,"Endpoint Must Be Covered By (Line-Point)"
                                      ,os.path.join(dataset_path, 'Centerline')
                                      ,""
                                      ,os.path.join(dataset_path, 'Node')
                                      ,"")
    
    logger.info('Adding rule 5 to {0}'.format(topology_path))
    arcpy.management.AddRuleToTopology(topology_path
                                      ,"Must Not Overlap (Line)"
                                      ,os.path.join(dataset_path, 'Centerline')
                                      ,""
                                      ,""
                                      ,"")
    
    logger.info('Adding rule 6 to {0}'.format(topology_path))
    arcpy.management.AddRuleToTopology(topology_path
                                      ,"Must Not Self-Intersect (Line)"
                                      ,os.path.join(dataset_path, 'Centerline')
                                      ,""
                                      ,""
                                      ,"")
    
    logger.info('Adding rule 7 to {0}'.format(topology_path))
    arcpy.management.AddRuleToTopology(topology_path
                                      ,"Must Be Single Part (Line)"
                                      ,os.path.join(dataset_path, 'Centerline')
                                      ,""
                                      ,""
                                      ,"")
    
    logger.info('Adding rule 8 to {0}'.format(topology_path))
    arcpy.management.AddRuleToTopology(topology_path
                                      ,"Must Not Intersect Or Touch Interior (Line)"
                                      ,os.path.join(dataset_path, 'Centerline')
                                      ,""
                                      ,""
                                      ,"")

    logger.info('Completed topology work {0} in {1}'.format(topology.name
                                                           ,os.path.join(gdb
                                                                        ,featuredataset.itempath)
                                                           ))
    return 1

if __name__ == '__main__':

    ptargetgdb = sys.argv[1]

    timestr = time.strftime("%Y%m%d-%H%M%S")

    # ..\logs\finalizeloadcscl-20250403-160745.log
    targetlog = os.path.join(os.environ['TARGETLOGDIR']
                            ,'finalizeloadcscl-{0}.log'.format(timestr))

    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s - %(levelname)s - %(message)s',
        filename=targetlog,
        filemode='w'
    )

    try:
        toporetval = 0
        toporetval = create_topology(ptargetgdb)
    except:
        logging.error('create_topology bombed check the log')
        sys.exit(1)
    finally:
        if toporetval != 1:
            logging.error('create_topology bombed check the log')
            sys.exit(1)

    listbuckets = Resourcelistmanager('listoflists').names
    logging.debug('lists in  play {0}'.format(listbuckets))

    listisversioned = Resourcelistmanager('listofversionedlists').names
    logging.debug('versioned lists in play {0}'.format(listisversioned))

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
                
                if granted == 1:

                    logging.info("failed to grant view on {0} to {1}".format(gdbitem
                                                                            ,readonlyuser))
                    
            for editor in editors:

                granted = csclelement.grant(ptargetgdb
                                           ,'EDIT'
                                           ,editor)
                
                if granted == 1:

                    logging.info("failed to grant edit on {0} to {1}".format(gdbitem
                                                                            ,editor))

    logging.info("{0} load complete. Spread love. Its the Brooklyn way".format(ptargetgdb))

    sys.exit(0)