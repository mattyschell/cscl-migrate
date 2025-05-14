import os
import time
import sys
import logging
# import arcpy


class Resourcelistmanager(object):

    # fun little class :0) clown

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

        self.gdbtype = self.getgdbtype()

        self.featuredataset = self.getfeaturedataset()

    def getgdbtype(self):

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

            # just one (for now) deceitful feature dataset
        
            if self.name in Resourcelistmanager(featuredatasetname).names:
                return featuredatasetname
            else:
                return None

    