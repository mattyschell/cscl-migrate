import unittest
import os
import arcpy

import filegeodatabasemanager
import version_manager

# this is not important enough to mock up
# call on an enterprise geodatabase to test once or twice and then
# leave the tests fallow.  Terrible idea but no one is reading this

class VersionManagerTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(self):

        self.geodatabase = os.environ['SDEFILE']
        self.name        = 'TESTVERSION'
        self.version     = version_manager.Version(self.geodatabase
                                                  ,self.name)

    @classmethod
    def tearDownClass(self):

        self.version.delete()

    def test_aschemaname(self):

        self.assertIsNotNone(self.version.schemaname())
        self.assertGreater(len(self.version.schemaname()),0)

    def test_bfully_qualified_name(self):

        self.assertIn('.', self.version.fully_qualified_name())

    def test_cexists(self):

        self.assertFalse(self.version.exists())

    def test_ddeletenoexist(self):

        self.assertIsNone(self.version.delete())

    def test_ecreate(self):

        result = self.version.create()
        self.assertIsNone(result)
        self.assertTrue(self.version.exists())
        

if __name__ == '__main__':
    unittest.main()