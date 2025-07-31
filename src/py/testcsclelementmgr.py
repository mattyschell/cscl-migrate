import unittest
import os
import pathlib

import csclelementmgr

# C:\Users\<user>\AppData\Local\Programs\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
#   ./src/py/testcsclelementmgr.py

class CsclelementmgrTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(self):

        self.centerlinefeatureclass = csclelementmgr.CSCLElement('Centerline')

        self.streetnametable = csclelementmgr.CSCLElement('STREETNAME')

        self.csclfeaturedataset = csclelementmgr.CSCLElement('CSCL')

        self.charelationshipclass = csclelementmgr.CSCLElement('CenterlinesHaveAddresses')

        self.cscltopology = csclelementmgr.CSCLElement('CSCL_Topology')

        self.archiveclass = csclelementmgr.CSCLElement('ADDRESSPOINT_H')

        self.domain = csclelementmgr.CSCLElement('dYesNo')

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
        self.assertEqual(self.centerlinefeatureclass.grant('nope.sde','VIEW','MALTAGOYA'),1)

        # exit 0 success grants dont exist for these
        self.assertEqual(self.cscltopology.grant('nope.sde','VIEW','MALTAGOYA'),0)
        self.assertEqual(self.charelationshipclass.grant('nope.sde','VIEW','MALTAGOYA'),0)
        self.assertEqual(self.domain.grant('nope.sde','VIEW','MALTAGOYA'),0)
        
    def testharchivclass(self):

        self.assertEqual(self.archiveclass.name,'ADDRESSPOINT_H')

        self.assertIsNone(self.archiveclass.featuredataset)

        self.assertEqual(self.archiveclass.gdbtype, 'archiveclass')

        self.assertEqual(self.archiveclass.tolerance, .00328083333333333)

        self.assertEqual(self.archiveclass.resolution, .000328083333333333)

    def testidomain(self):

        self.assertEqual(self.domain.name,'dYesNo')

        self.assertIsNone(self.domain.featuredataset)

        self.assertEqual(self.domain.gdbtype, 'domain')


if __name__ == '__main__':
    unittest.main()