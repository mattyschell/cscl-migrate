import unittest
import os
import pathlib

import csclelementmgr

# C:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
#   ./src/py/testcsclelementmgr.py

class CsclelementmgrTestCase(unittest.TestCase):

    def test_afeatureclass(self):

        # case sensitive
        afeatureclass = csclelementmgr.CSCLElement('Centerline')
        
        self.assertEqual(afeatureclass.name,'Centerline')

        self.assertEqual(afeatureclass.featuredataset, 'CSCL')

        self.assertEqual(afeatureclass.gdbtype, 'featureclass')

        self.assertEqual(afeatureclass.tolerance, .00328083333333333)

    def testbtable(self):

        atable = csclelementmgr.CSCLElement('STREETNAME')
        
        self.assertEqual(atable.name,'STREETNAME')

        self.assertIsNone(atable.featuredataset)

        self.assertEqual(atable.gdbtype, 'featuretable')

        self.assertIsNone(atable.tolerance)

    def testcdeceitfulfeaturedataset(self):

        adeceitfulfeaturedataset = csclelementmgr.CSCLElement('CSCL')
        
        self.assertEqual(adeceitfulfeaturedataset.name,'CSCL')

        self.assertIsNone(adeceitfulfeaturedataset.featuredataset)

        self.assertEqual(adeceitfulfeaturedataset.gdbtype, 'featuredataset')

        self.assertEqual(adeceitfulfeaturedataset.tolerance, .00328083333333333)

    def testdrelationshipclass(self):

        arelationshipclass = csclelementmgr.CSCLElement('CenterlinesHaveAddresses')

        self.assertEqual(arelationshipclass.name,'CenterlinesHaveAddresses')
        
        self.assertEqual(arelationshipclass.featuredataset,'CSCL')

        self.assertEqual(arelationshipclass.gdbtype, 'relationshipclass')

        self.assertIsNone(arelationshipclass.tolerance)

    def testetopology(self):

        atopology = csclelementmgr.CSCLElement('CSCL_Topology')

        self.assertEqual(atopology.name,'CSCL_Topology')
        
        self.assertEqual(atopology.featuredataset,'CSCL')

        self.assertEqual(atopology.gdbtype, 'topology')

        self.assertIsNone(atopology.tolerance)

    def testfexists(self):

        afeatureclass = csclelementmgr.CSCLElement('Centerline')

        self.assertFalse(afeatureclass.exists('C:\\dev\\null'))



if __name__ == '__main__':
    unittest.main()