import os
import time
import sys
import logging
import arcpy


class Resourcelistmanager(object):

    # fun little class :0) clown
    # and why is it everywhere

    def __init__(self
                ,whichlist):

        with open(os.path.join(os.path.dirname(__file__)
                              ,'resources'
                              ,whichlist)) as l:
            
            contents = [line.strip() for line in l]

        self.names = contents  

class CSCLElement(object):

    def __init__(self
                ,elementname):
         
        self.name = elementname

        # featureclass, featuredataset, etc
        self.gdbtype = self.getgdbtype()

        # if this element is a child of a deceitful featuredataset
        # this is the deceitful parents name (spoiler: its CSCL)
        self.featuredataset = self.getfeaturedataset()

        if self.featuredataset is None:
            self.itempath = self.name
        else:
            # todo: double check syntax do not care till error
            self.itempath = '{0}/{1}'.format(self.featuredataset
                                            ,self.name)  
            
    def exists(self
              ,gdb):

        if arcpy.Exists(os.path.join(gdb, self.itempath)):
            return True
        else:
            return False

    def getgdbtype(self):

        # what type of geodatabase item is self

        # EZ singular names. English can take the L
        typelist = ['featureclass'
                   ,'featuredataset'
                   ,'featuretable'
                   ,'relationshipclass'
                   ,'topology']
        
        for itemtype in typelist:
            if self.name in Resourcelistmanager('all' + itemtype).names:
                return itemtype
  
    def getfeaturedataset(self):

        # if self is in a feature dataset tell us the feature dataset name

        featuredatasets = Resourcelistmanager('allfeaturedataset').names

        for featuredatasetname in featuredatasets:

            # just one (for now) deceitful featuredataset to loop over
        
            if self.name in Resourcelistmanager(featuredatasetname).names:
                return featuredatasetname
            
        return None
    
    def version(self
               ,ptargetgdb):
        
        retval = 0

        if self.featuredataset is not None:
            # child of a deceitful feature dataset parent
            # the parent versions its children
            return 1
        
        logging.info('versioning {0}'.format(self.name))

        elementfullpath = os.path.join(ptargetgdb, self.itempath)

        try:
            arcpy.management.RegisterAsVersioned(elementfullpath)
            return 1
        except arcpy.ExecuteError:
            logging.error('RegisterAsVersioned error on {0}: {1}'.format(elementfullpath
                                                                        ,arcpy.GetMessages(2)))
        except Exception as e:
            print('RegisterAsVersioned unexpected error on {0}: {1}'.format(elementfullpath
                                                                           ,e))
 
        return retval
    
    def grant(self
             ,ptargetgdb
             ,esripriv
             ,esriuser):

        elementfullpath = os.path.join(ptargetgdb, self.itempath)

        if esripriv == 'VIEW':

            try:
                arcpy.management.ChangePrivileges(elementfullpath
                                                ,esriuser
                                                ,'GRANT'
                                                ,'AS_IS') 
                return 1
            
            except:
                
                return 0

        elif esripriv == 'EDIT':

            try:

                arcpy.management.ChangePrivileges(elementfullpath
                                                ,esriuser
                                                ,'AS_IS'
                                                ,'GRANT') 
                return 1
            
            except:
                
                return 0

       

    
