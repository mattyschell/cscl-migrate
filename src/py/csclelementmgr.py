import os
import time
import sys
import logging
import arcpy


class Resourcelistmanager(object):

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
        self.istable = self.gettupletypes()

        # if this element is a child of a deceitful featuredataset
        # this is the deceitful parents name (spoiler: its CSCL)
        self.featuredataset = self.getfeaturedataset()

        if self.featuredataset is None:
            self.itempath = self.name
        else:
            # todo: double check syntax do not care till error
            self.itempath = '{0}/{1}'.format(self.featuredataset
                                            ,self.name)  
        
        if self.gdbtype in ('featureclass','featuredataset','archiveclass'):
            self.tolerance  = .00328083333333333
            self.resolution = .000328083333333333
        else:
            self.tolerance  = None
            self.resolution = None

    def getgdbtype(self):

        # what type of geodatabase item is this

        # EZ singular names. English can take the L
        typelist = ['featureclass'
                   ,'featuredataset'
                   ,'featuretable'
                   ,'relationshipclass'
                   ,'topology'
                   ,'archiveclass'
                   ,'domain']
        
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

    def exists(self
              ,gdb):

        if arcpy.Exists(os.path.join(gdb, self.itempath)):
            return True
        else:
            return False   

    def count(self
             ,gdb):

        if self.istable:
            try:
                kount = int(arcpy.management.GetCount(os.path.join(gdb,self.itempath))[0])
            except arcpy.ExecuteError:
                kount = 0
            return kount
        else:
            return None

    def gettupletypes(self):

        if self.gdbtype in ('featureclass','featuretable','archiveclass'): 
            return True
        else:
            return False
    
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

        if  self.gdbtype not in ('relationshipclass','topology','domain') \
        and self.featuredataset is None:
          
            if esripriv == 'VIEW':

                try:
                    arcpy.management.ChangePrivileges(elementfullpath
                                                     ,esriuser
                                                     ,'GRANT'
                                                     ,'AS_IS') 
                    return 0
                
                except:

                    return 1
    
            elif esripriv == 'EDIT':
    
                try:
    
                    arcpy.management.ChangePrivileges(elementfullpath
                                                     ,esriuser
                                                     ,'GRANT'
                                                     ,'GRANT') 
                    return 0
                
                except:
                    
                    return 1
                
        else:

            return 0

       

    
