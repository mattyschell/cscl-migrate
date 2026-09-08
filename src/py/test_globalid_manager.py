import os
import shutil
import tempfile
import unittest

import arcpy

import globalid_manager


class GlobalIdManagerTestCase(unittest.TestCase):

    def setUp(self):
        self.tempdir = tempfile.mkdtemp()
        self.gdb = os.path.join(self.tempdir, 'globalid-test.gdb')
        arcpy.management.CreateFileGDB(self.tempdir, 'globalid-test.gdb')

        self.table = os.path.join(self.gdb, 'TestTable')
        arcpy.management.CreateTable(self.gdb, 'TestTable')
        arcpy.management.AddField(self.table, 'TESTVALUE', 'TEXT')
        arcpy.management.AddGlobalIDs(self.table)
        with arcpy.da.InsertCursor(self.table, ['TESTVALUE']) as rows:
            rows.insertRow(['table'])

        self.featureclass = os.path.join(self.gdb, 'TestFeatureClass')
        arcpy.management.CreateFeatureclass(
            self.gdb,
            'TestFeatureClass',
            'POINT',
            spatial_reference=arcpy.SpatialReference(2263)
        )
        arcpy.management.AddGlobalIDs(self.featureclass)
        with arcpy.da.InsertCursor(self.featureclass, ['SHAPE@']) as rows:
            rows.insertRow([arcpy.Point(0, 0)])

    def tearDown(self):
        shutil.rmtree(self.tempdir, ignore_errors=True)

    def assert_globalids_preserved(self, dataset_path):
        source_values = [
            row[0]
            for row in arcpy.da.SearchCursor(dataset_path, ['GLOBALID'])
        ]

        self.assertEqual(globalid_manager.preserve_globalid(dataset_path), 1)

        fields = {
            field.name.upper(): field
            for field in arcpy.ListFields(dataset_path)
        }
        self.assertIn('BASEGLOBALID', fields)
        self.assertEqual(fields['BASEGLOBALID'].type, 'String')
        self.assertEqual(fields['BASEGLOBALID'].length, 38)

        preserved_values = [
            row[0]
            for row in arcpy.da.SearchCursor(dataset_path, ['BASEGLOBALID'])
        ]
        self.assertEqual(source_values, preserved_values)

        self.assertEqual(globalid_manager.preserve_globalid(dataset_path), 0)
        repeated_values = [
            row[0]
            for row in arcpy.da.SearchCursor(dataset_path, ['BASEGLOBALID'])
        ]
        self.assertEqual(source_values, repeated_values)

    def test_table_globalids_are_preserved(self):
        self.assert_globalids_preserved(self.table)

    def test_featureclass_globalids_are_preserved(self):
        self.assert_globalids_preserved(self.featureclass)


if __name__ == '__main__':
    unittest.main()