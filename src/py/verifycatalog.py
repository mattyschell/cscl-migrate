import sys
import os
import logging
import datetime
import time
import arcpy


def fetchlist(whichlist):

    with open(os.path.join(os.path.dirname(__file__)
                          ,'resources'
                          ,whichlist)) as l:

        contents = [line.strip() for line in l if line.strip()]

    return contents  

def filterschema(gdbobjects
                ,schema='CSCL'):

    #input
    #   CSCL.ADDRESSPOINT
    #   JDOE.FOO
    #   CSCL_PUB.ADDRESSPOINT
    #output
    #   CSCL.ADDRESSPOINT

    cleangdbobjects = []

    for gdbobject in gdbobjects:
        if gdbobject.startswith('{0}.'.format(schema)):
            cleangdbobjects.append(gdbobject.partition('.')[2])
        elif not "." in gdbobject:
            # NA for file gdb
            cleangdbobjects.append(gdbobject)
    
    return cleangdbobjects


def get_relationshipclasses(workspace):

    relclasses = []
    walk = arcpy.da.Walk(workspace
                        ,datatype="RelationshipClass")

    for dirpath, dirnames, filenames in walk:
        for relationshipclass in filenames:
            relclasses.append(relationshipclass)

    return filterschema(relclasses)

def get_topologies(workspace):

    # consider combining all of these to limit arcpy.da.Walk calls
    topologies = []
    walk = arcpy.da.Walk(workspace
                        ,datatype="Topology")

    for dirpath, dirnames, filenames in walk:
        for topology in filenames:
            topologies.append(topology)

    return filterschema(topologies)

def get_tables():

    return filterschema(arcpy.ListTables())

def get_feature_datasets():
    
   return filterschema(arcpy.ListDatasets())

def get_feature_classes():

    feature_classes = arcpy.ListFeatureClasses()

    for dataset in arcpy.ListDatasets():
        dataset_fcs = arcpy.ListFeatureClasses(feature_dataset = dataset)

        #add feature classes to ongoing list
        for fc in dataset_fcs:
            feature_classes.append(fc)

    return filterschema(feature_classes)

def getallobjects(workspace):

    return get_tables() \
         + get_feature_datasets() \
         + get_feature_classes() \
         + get_relationshipclasses(workspace) \
         + get_topologies(workspace)

if __name__ == "__main__":

    # this must be a list of lists
    # if we only want to check tables for example
    # make a list with one element: tables
    # case is sensitive
    listname   = sys.argv[1]

    gdb2verify = os.environ['SDEFILE']
    arcpy.env.workspace = gdb2verify

    timestr = time.strftime("%Y%m%d-%H%M%S")
    # ..\logs\verifycatalog-ditcsdv1-20250403-160745.log
    targetlog = \
        os.path.join(os.environ['TARGETLOGDIR'] 
                    ,'verifycatalog-{0}-{1}.log'.format(os.path.basename(gdb2verify).split(".")[0]
                                                        ,timestr))

    logging.basicConfig (
        level=logging.DEBUG,  
        format='%(asctime)s - %(levelname)s - %(message)s',  
        handlers=[
            logging.FileHandler(targetlog),  # log messages 
            logging.StreamHandler()          # cc: screen 
        ]
    )
    logger = logging.getLogger(__name__)
    
    logger.info('starting catalog verification of {0} at {1}'.format(gdb2verify
                                                                    ,datetime.datetime.now()))

    # what can this user see
    existingobjects = getallobjects(arcpy.env.workspace)

    listnames = fetchlist(listname) 

    expectedobjects = []
    
    for name in listnames:

        objectnames = fetchlist(name) 
        expectedobjects = expectedobjects + objectnames

    # we dont check the other direction (for now)
    # extra objects are allowed
    expectednotexisting = set(expectedobjects).difference(set(existingobjects))

    if len(expectednotexisting) == 0:
        logger.info('Verified {0} geodatabase objects'.format(len(expectedobjects)))
        logger.info('PASS: completed qa of {0} at at {1}'.format(gdb2verify
                                                                ,datetime.datetime.now()))
    else:
        for missing in expectednotexisting:
            logger.warning('{0} is missing!'.format(missing))




