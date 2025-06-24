import unittest
import os
import pathlib

import csclelementmgr

# C:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
#   ./src/py/testcsclelementmgr.py

class CsclelementmgrTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(self):

        self.centerlinefeatureclass = csclelementmgr.CSCLElement('Centerline')

        self.streetnametable = csclelementmgr.CSCLElement('STREETNAME')

        self.csclfeaturedataset = csclelementmgr.CSCLElement('CSCL')

        self.charelationshipclass = csclelementmgr.CSCLElement('CenterlinesHaveAddresses')

        self.cscltopology = csclelementmgr.CSCLElement('CSCL_Topology')

    def test_afeatureclass(self):
        
        self.assertEqual(self.centerlinefeatureclass.name,'Centerline')

        self.assertEqual(self.centerlinefeatureclass.featuredataset, 'CSCL')

        self.assertEqual(self.centerlinefeatureclass.gdbtype, 'featureclass')

        self.assertEqual(self.centerlinefeatureclass.tolerance, .00328083333333333)

    def testbtable(self):
        
        self.assertEqual(self.streetnametable.name,'STREETNAME')

        self.assertIsNone(self.streetnametable.featuredataset)

        self.assertEqual(self.streetnametable.gdbtype, 'featuretable')

        self.assertIsNone(self.streetnametable.tolerance)

    def testcdeceitfulfeaturedataset(self):
        
        self.assertEqual(self.csclfeaturedataset.name,'CSCL')

        self.assertIsNone(self.csclfeaturedataset.featuredataset)

        self.assertEqual(self.csclfeaturedataset.gdbtype, 'featuredataset')

        self.assertEqual(self.csclfeaturedataset.tolerance, .00328083333333333)

    def testdrelationshipclass(self):

        self.assertEqual(self.charelationshipclass.name,'CenterlinesHaveAddresses')
        
        self.assertEqual(self.charelationshipclass.featuredataset,'CSCL')

        self.assertEqual(self.charelationshipclass.gdbtype, 'relationshipclass')

        self.assertIsNone(self.charelationshipclass.tolerance)

    def testetopology(self):

        self.assertEqual(self.cscltopology.name,'CSCL_Topology')
        
        self.assertEqual(self.cscltopology.featuredataset,'CSCL')

        self.assertEqual(self.cscltopology.gdbtype, 'topology')

        self.assertIsNone(self.cscltopology.tolerance)

    def testfexists(self):

        self.assertFalse(self.centerlinefeatureclass.exists('C:\\dev\\null'))

    def testggrants(self):

        # fail
        self.assertEqual(self.centerlinefeatureclass.grant('nope.sde','VIEW','MALTAGOYA'),0)

        # exit none
        self.assertIsNone(self.cscltopology.grant('nope.sde','VIEW','MALTAGOYA'))
        self.assertIsNone(self.charelationshipclass.grant('nope.sde','VIEW','MALTAGOYA'))
        

if __name__ == '__main__':
    unittest.main()