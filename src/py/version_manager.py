import arcpy
import os

# versions inherit from a small shared base class
from csclelementmgr import GeodatabaseElement

class Version(GeodatabaseElement):

    def __init__(self
                ,geodatabase
                ,name 
                ,parent='SDE.DEFAULT'
                ,access='PUBLIC'):

        # fullpath and schema name are so far the only useful methods 
        # inherited from GeodatabaseElement 
        
        # python 2 and 3 compatible
        super(Version, self).__init__(name)

        self.geodatabase = geodatabase
        self.name        = name         # just name no schema
        self.parent      = parent
        self.access      = access

    def fully_qualified_name(self):

        # schemaname is inherited from GeodatabaseElement 
        schema = self.schemaname().lower()

        if "." in self.name:
            return self.name
        else:
            return '{0}.{1}'.format(self.schemaname()
                                   ,self.name)

    def exists(self):

        # override GeodatabaseElement exists
        # exists is fully qualified name
        return any(v.name.lower() == self.fully_qualified_name().lower() 
                   for v in 
                       arcpy.da.ListVersions(self.geodatabase)
                  ) 

    def delete(self):

        if self.exists():

            # delete is not fully qualified
            arcpy.management.DeleteVersion(self.geodatabase
                                          ,self.name)

    def create(self):

        if not self.exists():
        
            # create is not fully qualified
            arcpy.management.CreateVersion(self.geodatabase
                                          ,self.parent
                                          ,self.name
                                          ,self.access)
    
    # for migration we only need to create
    # no need for alter, rec/post etc
    
