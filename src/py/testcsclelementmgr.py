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

    def testbtable(self):

        # case sensitive
        atable = csclelementmgr.CSCLElement('STREETNAME')
        
        self.assertEqual(atable.name,'STREETNAME')

        self.assertIsNone(atable.featuredataset)

        self.assertEqual(atable.gdbtype, 'featuretable')

    def testcdeceitfulfeaturedataset(self):

        # case sensitive
        adeceitfulfeaturedataset = csclelementmgr.CSCLElement('CSCL')
        
        self.assertEqual(adeceitfulfeaturedataset.name,'CSCL')

        self.assertIsNone(adeceitfulfeaturedataset.featuredataset)

        self.assertEqual(adeceitfulfeaturedataset.gdbtype, 'featuredataset')


if __name__ == '__main__':
    unittest.main()