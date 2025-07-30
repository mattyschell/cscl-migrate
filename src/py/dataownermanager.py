import arcpy

class DataOwner(object):

    def __init__(self
                ,workspace):

        # so many slightly different versions of this!

        self.workspace = workspace
        
        desc = arcpy.Describe(arcpy.env.workspace)
        
        if hasattr(desc, "connectionProperties"):

            # enterprise geodatabase
            # this will be lower case
        
            self.user = desc.connectionProperties.user

        else: 

            self.user = None

    def filterschema(self
                    ,gdbobjects):
        
        if self.user is None:
            # file geodatabase
            return gdbobjects

        # input
        #   CSCL.ADDRESSPOINT
        #   JDOE.FOO
        #   CSCL_PUB.ADDRESSPOINT
        # output
        #   CSCL.ADDRESSPOINT

        cleangdbobjects = []

        # must go case insensitive workspace user schema is lowercase

        for gdbobject in gdbobjects:
            
            if gdbobject.lower().startswith('{0}.'.format(self.user.lower())):
                cleangdbobjects.append(gdbobject.partition('.')[2])
            
            #elif not "." in gdbobject:
            #    # this should not happen 
            #    cleangdbobjects.append(gdbobject)
        
        return cleangdbobjects

    def get_domains(self):

        # domains are not individual data elements
        # they are geodatabase metadata
        domains = arcpy.da.ListDomains(self.workspace)

        # workspace should filter schema
        domainnames = [domain.name for domain in domains]

        return domainnames

    def get_relationshipclasses(self):

        relclasses = []
        walk = arcpy.da.Walk(self.workspace
                            ,datatype="RelationshipClass")

        for dirpath, dirnames, filenames in walk:
            for relationshipclass in filenames:
                relclasses.append(relationshipclass)

        return self.filterschema(relclasses)

    def get_topologies(self):

        topologies = []
        walk = arcpy.da.Walk(self.workspace
                            ,datatype="Topology")

        for dirpath, dirnames, filenames in walk:
            for topology in filenames:
                topologies.append(topology)

        return self.filterschema(topologies)

    def get_tables(self):

        return self.filterschema(arcpy.ListTables())

    def get_feature_datasets(self):
    
        return self.filterschema(arcpy.ListDatasets())

    def get_feature_classes(self):

        feature_classes = arcpy.ListFeatureClasses()

        for dataset in arcpy.ListDatasets():
            dataset_fcs = arcpy.ListFeatureClasses(feature_dataset = dataset)

            #add feature classes to ongoing list
            for fc in dataset_fcs:
                feature_classes.append(fc)

        return self.filterschema(feature_classes)

    def getallobjects(self):

        return self.get_tables() \
             + self.get_feature_datasets() \
             + self.get_feature_classes() \
             + self.get_relationshipclasses() \
             + self.get_topologies() \
             + self.get_domains()
