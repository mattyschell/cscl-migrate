import os
import time
import sys
import logging
import arcpy

from resourcemanager import listmanager


class GeodatabaseElement(object):

    def __init__(self
                ,name):

        self.name = name
        self.featuredataset = None
        self.itempath = name
        self.geodatabase = None

    def fullpath(self
                ,gdb):

        return os.path.join(gdb
                           ,self.itempath)

    def exists(self
              ,gdb=None):
        
        actualgdb = self.geodatabase if self.geodatabase is not None else gdb
        return arcpy.Exists(self.fullpath(actualgdb))

    def copyto(self
              ,geodatabase):

        # object copy not database copy
        output = self.__class__.__new__(self.__class__)
        output.__dict__ = self.__dict__.copy()
        output.geodatabase = geodatabase
        return output

class CSCLElement(GeodatabaseElement):

    def __init__(self
                ,elementname):

        #python 2 and 3 compatible
        super(CSCLElement, self).__init__(elementname)
         
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
                   ,'domain'
                   ,'attributedrelationshipclass']
            
        for itemtype in typelist:
            lm = listmanager('all' + itemtype)
            if self.name in lm.names:
                return itemtype
  
    def getfeaturedataset(self):

        # if self is in a feature dataset tell us the feature dataset name

        featuredatasets = listmanager('allfeaturedataset').names

        for featuredatasetname in featuredatasets:

            # just one (for now) deceitful featuredataset to loop over
            if self.name in listmanager(featuredatasetname).names:
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

        kount = 0
        if self.istable and self.exists(gdb):
            try:
                kount = int(arcpy.management.GetCount(os.path.join(
                                                      gdb
                                                     ,self.itempath))[0])
            except arcpy.ExecuteError:
                raise

        return kount

    def gettupletypes(self):

        if self.gdbtype in ('featureclass'
                           ,'featuretable'
                           ,'archiveclass'
                           ,'attributedrelationshipclass'): 
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
            logging.error('RegisterAsVersioned error on {0}: {1}'.format(
                elementfullpath
               ,arcpy.GetMessages(2)))
        except Exception as e:
            print('RegisterAsVersioned unexpected error on {0}: {1}'.format(
                elementfullpath
               ,e))
 
        return retval

    def _change_priv(self
                    ,elementfullpath
                    ,esriuser
                    ,grant):

        try:
            arcpy.management.ChangePrivileges(
                elementfullpath,
                esriuser,
                'GRANT',
                grant
            )
            return 0, None   # success
        except Exception as ex:
            return 1, str(ex)  # failure + message
    
    def grant(self
             ,ptargetgdb
             ,esripriv
             ,esriuser):

        elementfullpath = os.path.join(ptargetgdb
                                      ,self.itempath)

        if self.gdbtype not in ('relationshipclass'
                               ,'topology'
                               ,'domain') \
        and self.featuredataset is None:

            if esripriv == 'VIEW':
                return self._change_priv(elementfullpath
                                        ,esriuser
                                        ,'AS_IS')

            elif esripriv == 'EDIT':
                return self._change_priv(elementfullpath
                                        ,esriuser
                                        ,'GRANT')
        else:
            return 0, None
