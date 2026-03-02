import unittest
import os
from pathlib import Path
import tempfile

import filegeodatabasemanager
import relationshipclass_manager

class RelationshipClassManagerTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(self):

        self.tempdir = Path(tempfile.gettempdir())
        self.testdatadir = os.path.join(
            os.path.dirname(os.path.abspath(__file__))
           ,'testdata')
        # this geodatabase has one feature class nybb (borough) in 2263
        # and one table NEIGHBORHOODS
        self.sourcepath = os.path.join(self.testdatadir
                                     ,'sample.gdb')
        self.sourcegdb    = filegeodatabasemanager.localgdb(self.sourcepath)
        # create in setup    
        self.testgdbpath    = os.path.join(self.tempdir
                                          ,'test.gdb')
        self.testrelclassname = 'Boroughs_Neighborhoods_Rel' 
        # for standard relationship classes this is a direct link
        # nybb.BoroCode <--> neighborhoods.BOROCODE   
        # the columns live on the base tables
        self.testoriginprimarykey = 'BoroCode'    
        self.testoriginforeignkey = 'BOROCODE'    
        # for many_to_many and attributed relationship classes the links shift
        # nybb.BoroCode <---> relationshipclass.origin_foreign_key
        # relationshipclass.destination_foreign_key <-->
        #                                neighborhoods.destination_primary_key        

    def setUp(self):

        self.testgdb  = filegeodatabasemanager.localgdb(self.testgdbpath)
        self.testgdb.clean()

        # will create and delete an tghis scratch gdb for each test
        self.sourcegdb.copy(self.testgdbpath)
        self.testgdb  = filegeodatabasemanager.localgdb(self.testgdbpath)
        self.boroughfc = 'nybb'
        self.neighborhoodtable = 'NEIGHBORHOODS'

        self.testrelclass = (
            relationshipclass_manager.RelationshipClass(
                self.testgdb.gdb
               ,self.testrelclassname)
        )

        # TODO: test with featuredataset
        self.testrelclass.origin_itempath = self.boroughfc
        self.testrelclass.destination_itempath = self.neighborhoodtable
        self.testrelclass.origin_primary_key = self.testoriginprimarykey
        self.testrelclass.origin_foreign_key = self.testoriginforeignkey

    def tearDown(self):

        self.testgdb.clean()

    @classmethod
    def tearDownClass(self):
        pass
        
    def test_aexists(self):

        self.assertFalse(self.testrelclass.exists())

    def test_bcreate(self):

        self.testrelclass.create()
        self.assertTrue(self.testrelclass.exists())

    def test_cdelete(self):

        self.testrelclass.create()
        self.assertTrue(self.testrelclass.exists())
        self.testrelclass.delete()
        self.assertFalse(self.testrelclass.exists())

    def test_ddescribe(self):

        self.testrelclass.create()
        result = self.testrelclass.describe_in_gdb()
        self.assertIsInstance(result, dict)
        # empty is False
        self.assertTrue(result)

    def test_edescribepretty(self):

        self.testrelclass.create()
        result = self.testrelclass.describe_pretty(
            self.testrelclass.describe_in_gdb()
        )
        self.assertIn('name', result)
        self.assertIn('Boroughs_Neighborhoods_Rel', result)
        self.assertIn('cardinality', result)
        # note annoying difference between input ONE_TO_MANY
        # and desc OneToMany
        self.assertIn('OneToMany', result)  
        # line breaks are pretty
        self.assertGreater(result.count('\n'), 0)  

    def test_fcopy(self):

        clone = self.testrelclass.copyto(self.testgdb.gdb) 
        # different instance
        self.assertIsNot(self.testrelclass, clone) 
        # same attributes (works here because same gdb)
        self.assertEqual(self.testrelclass.__dict__, clone.__dict__) 
        clone.create()
        self.assertTrue(clone.exists())
        
    def test_gdescribe_instance(self):

        result = self.testrelclass.describe_instance()
        self.assertIsInstance(result, dict)
        # empty is False
        self.assertTrue(result)

    def test_fdescribe_instance_pretty(self):

        result = self.testrelclass.describe_pretty(
            self.testrelclass.describe_instance()
        )
        self.assertIn('name', result)
        self.assertIn('Boroughs_Neighborhoods_Rel', result)
        self.assertIn('cardinality', result)
        # note real world ONE_TO_MANY in the instance
        # isntead of OneToMany returned by arcpy.desc
        self.assertIn('ONE_TO_MANY', result)  
        # line breaks are pretty
        self.assertGreater(result.count('\n'), 0) 

    def test_gcreateattributed(self):

        # standard attributed relationship class
        self.testrelclass.attributed = 'ATTRIBUTED'
        # create a column on the attributed table named BOROCODE 
        # this will link to Borough.BoroCode 
        # which is in test setup as self.testrelclass.origin_primary_key 
        self.testrelclass.origin_foreign_key = 'BoroCode'
        # create a column on the attributed table named NEIHBORHOODOBJECTID
        self.testrelclass.destination_foreign_key = 'NEIGHBORHOODOBJECTID'
        # which links to objectid on neighborhoods
        self.testrelclass.destination_primary_key = 'OBJECTID'
        # note that neighborhoods.BOROCODE is defunct in this example
        self.testrelclass.create()
        self.assertTrue(self.testrelclass.exists())
        result = self.testrelclass.describe_in_gdb()
        # arcpy.Describe is True of False. Create takes ATTRIBUTED or 'NONE'
        self.assertTrue(result.get("isAttributed"))

    def test_hcreatecomposite(self):

        self.testrelclass.relationship_type = 'COMPOSITE'
        self.testrelclass.create()
        self.assertTrue(self.testrelclass.exists())
        self.assertTrue(self.testrelclass.describe_in_gdb().get("isComposite"))

    def test_icreatefromrelationship(self):

        # Table To Relationship Class
        # uses an input junction table (aka relationship table) to populate 
        # additional columns in the attributed relationship class
        # The input junction table here is named NEIGHBORHOODDATA
        # it contains a column PERCENTBOROCOOLNESS indicating what 
        # percent of borough rizz comes from that neighborhood
        # That column (and data) will be added to the attributed rel class
        # The input relationship table NEIGHBORHOODDATA does NOT participate
        # in the relationship going forward.
        # As the number of commented lines here indicates this thing is messy.
        # use judiciously
        self.testrelclass.relationship_table = 'neighborhooddata' 
        self.testrelclass.attribute_fields = ['PERCENTBOROCOOLNESS']
        # see createattributed test above for these bad boys
        # some of these are already set. Re-stating them for obviousness
        self.testrelclass.attributed = 'ATTRIBUTED'
        self.testrelclass.origin_foreign_key = 'BOROCODE'
        self.testrelclass.destination_foreign_key = 'Name'
        self.testrelclass.destination_primary_key = 'Name'
        self.testrelclass.create()
        self.assertTrue(self.testrelclass.exists())
        self.assertTrue(
            self.testrelclass.describe_in_gdb().get("isAttributed")
        )
        # I havent tested edits against this 
        # PERCENTBOROCOOLNESS | BOROCODE | Name            | RID 
        # 10                  | 3        | Red Hook        | 1
        # 100                 | 4        | Jackson Heights | 2

    def test_jcreatefromrelationshipwithglobalid(self):

        # This is the big boss battle:
        # given an existing attributed relationshipclass with globalids,
        # preserve the globalids
        # 1. Create a new column named NOTGLOBALID
        # 2. Populate with '{globalid}'s
        # 3. Use TableToRelationshipClass including NOTGLOBALID
        # 4. Add new GLOBALID to the attributed relationship class
        # 5. (out of scope here) Join NOTGLOBALID for archive migration
        # We start at step 3 in the test 
        self.testrelclass.relationship_table = 'neighborhooddata' 
        self.testrelclass.attribute_fields = ['PERCENTBOROCOOLNESS'
                                             ,'NOTGLOBALID']
        self.testrelclass.attributed = 'ATTRIBUTED'
        self.testrelclass.origin_foreign_key = 'BOROCODE'
        self.testrelclass.destination_foreign_key = 'Name'
        self.testrelclass.destination_primary_key = 'Name'
        self.testrelclass.create()
        self.assertTrue(self.testrelclass.exists())
        self.assertTrue(
            self.testrelclass.describe_in_gdb().get("isAttributed")
        )
        # PERCENTBOROCOOLNESS | NOTGLOBALID | BOROCODE | Name            | RID 
        # 10                  | {abc123}    | 3        | Red Hook        | 1
        # 100                 | {xyz890}    | 4        | Jackson Heights | 2

    def test_khasglobalid(self):

        # not much code coverage on this one
        self.testrelclass.create()
        self.assertFalse(self.testrelclass.hasglobalid())

    def test_laddglobalid(self):

        # CreateRelationshipClass and TableToRelationshipClass do not 
        # add globalids to baby relationship classes. We always require 
        # globalids on any attributed relationship class
        self.testrelclass.attributed = 'ATTRIBUTED'
        self.testrelclass.destination_foreign_key = 'NEIGHBORHOODOBJECTID'
        self.testrelclass.destination_primary_key = 'OBJECTID'
        self.testrelclass.create()
        self.testrelclass.addglobalid()
        self.assertTrue(self.testrelclass.hasglobalid())


if __name__ == '__main__':
    unittest.main()

       