import unittest
import os
import pathlib

import csclelementmgr


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


if __name__ == '__main__':
    unittest.main()