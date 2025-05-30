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
        # this is the deceitfule parents name (spoiler: its CSCL)
        self.featuredataset = self.getfeaturedataset()

        if self.featuredataset is None:
            self.itempath = self.name
        else:
            # todo: double check syntax do not care till error
            self.itempath = '{0}/{1}'.format(self.featuredataset
                                            ,self.name)  

    def getgdbtype(self):

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

        featuredatasets = Resourcelistmanager('allfeaturedataset').names

        for featuredatasetname in featuredatasets:

            # just one (for now) deceitful featuredataset to loop over
        
            if self.name in Resourcelistmanager(featuredatasetname).names:
                return featuredatasetname
            
        return None
    
    def copypaste(self
                 ,psrcgdb
                 ,ptargetgdb):
        
        retval = 0

        if self.gdbtype == 'featuredataset':
            return self.copypastefeaturedataset(psrcgdb
                                               ,ptargetgdb)
        

        srcitem = os.path.join(psrcgdb, self.itempath)
        targetitem = os.path.join(ptargetgdb, self.itempath)

        logging.debug("srcitem {0}".format(srcitem))
        logging.debug("targetitem {0}".format(targetitem))

        if arcpy.Exists(targetitem):

            logging.info('skipping already existing {0}'.format(targetitem))
            return retval

        try:
            arcpy.management.Copy(srcitem
                                 ,targetitem)
            
            if arcpy.Exists(targetitem):
                logging.info('Successfully copied {0} to {1}'.format(srcitem
                                                                    ,targetitem))
                return 1
            
            else:
                logging.error('Copy operation failed for {0}'.format(srcitem))
                return 0
        except arcpy.ExecuteError:
            logging.error(f"ArcPy error: {arcpy.GetMessages(2)}")
            return 0
        
        except Exception as e:
            logging.error(f"Unexpected error: {str(e)}")
            return 0
            
    def copypastefeaturedataset(self
                               ,psrcgdb
                               ,ptargetgdb):

        retval = 0

        # xx.gdb\CSCL
        # yy.sde\CSCL
        srcitem = os.path.join(psrcgdb, self.itempath)
        targetitem = os.path.join(ptargetgdb, self.itempath)
    
        if arcpy.Exists(targetitem):
            # all or nothing when migrating deceitful feature datasets
            logging.info('skipping already existing feature dataset {0}'.format(targetitem))
            return retval
        
        try:
            arcpy.management.CreateFeatureDataset(ptargetgdb
                                                 ,self.name
                                                 ,os.path.join(os.path.dirname(__file__)
                                                              ,'resources'
                                                              ,'epsg_2263.prj'))
            
            if arcpy.Exists(targetitem):
                logging.info('Successfully created {0}'.format(targetitem))
            else:
                logging.error('CreateFeatureDataset_management failed silently for {0}'.format(targetitem))
                return 0
            
        except arcpy.ExecuteError:
            logging.error(f"ArcPy error: {arcpy.GetMessages(2)}")
            return 0        
        except Exception as e:
            logging.error(f"Unexpected error: {str(e)}")
            return 0
        
        #loop over elements
        for childname in Resourcelistmanager(self.name).names:

            #feel clever now. mad at self.me later
            childretval = CSCLElement(childname).copypaste(psrcgdb
                                                          ,ptargetgdb)
            if childretval == 0:
                # all or nothing for deceitful feature datasets. exit on first 
                logging.info('child copy paste failed for {0}'.format(childname))

        return 1