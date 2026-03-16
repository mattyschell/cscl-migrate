import arcpy
import os
from pprint import pformat

# relationship classes inherit from a small shared base class
from csclelementmgr import GeodatabaseElement

class RelationshipClass(GeodatabaseElement):

    def __init__(self
                ,geodatabase
                ,name
                ,featuredataset = None
                ,origin = None
                ,destination = None
                ,relationship_type = 'SIMPLE'
                ,cardinality = 'ONE_TO_MANY'
                ,origin_primary_key = None
                ,destination_foreign_key = None
                ,attributed = 'NONE'
                ,attributed_table = None
                ,message_direction = 'NONE'
                ,notification = 'NONE'):

        # fullpath,exists,copy inherited from csclelementmgr.GeodatabaseElement 
        # python 2 and 3 compatible
        super(RelationshipClass, self).__init__(name)

        self.geodatabase    = geodatabase
        self.name           = name
        self.featuredataset = featuredataset

        if self.featuredataset is None:
            self.itempath = self.name
        else:
            # todo: double check syntax do not care till error
            self.itempath = '{0}/{1}'.format(self.featuredataset
                                            ,self.name)  

        # if necessary include featuredatasets on origin/destination_class
        # do not include geodatabase
        self.origin_itempath            = origin
        self.destination_itempath       = destination

        self.relationship_type       = (relationship_type or 'SIMPLE').upper()
        self.cardinality             = (cardinality or 'ONE_TO_MANY').upper()
        self.origin_primary_key      = origin_primary_key
        self.destination_foreign_key = destination_foreign_key
        self.attributed              = (attributed or 'NONE').upper()
        self.attributed_table        = attributed_table
        self.message_direction       = (message_direction or 'NONE').upper()
        self.notification            = (notification or 'NONE').upper()

        self.forward_label           = ''
        self.backward_label          = ''
        self.origin_foreign_key      = ''
        self.destination_primary_key = ''

        # rare: attributed relationship class with third junction table 
        self.relationship_table = ''
        self.attribute_fields = []

    def describe_in_gdb(self):
    
        # describe the geodatabase not the instance
        # returns a dict 

        if not self.exists():
            raise FileNotFoundError(
                'Relationship class does not exist: {0}'.format(
                    self.fullpath(self.geodatabase))
            )

        desc = arcpy.Describe(self.fullpath(self.geodatabase))

        # for some reason ESRI doesnt expose properties like originPrimaryKey
        # or destinationForeignKey on the relationship class. They are at 
        # the geodatabase level I guess?  
        # add more here if useful
        info = {
            "name": desc.name,
            "itempath": self.itempath,
            "fullpath": self.fullpath(self.geodatabase),
            "isComposite": desc.isComposite,
            "dataType": desc.dataType, # always RelationshipClass
            "originClassNames": desc.originClassNames,
            "destinationClassNames": desc.destinationClassNames,
            "cardinality": desc.cardinality,
            "isAttributed": desc.isAttributed,
            "attributedTable": getattr(desc, "attributedTable", None),
        }

        return info

    def describe_instance(self):
        
        return self.__dict__.copy()

    def describe_pretty(self, data):

        """
        Pretty print a dictionary.

        :param dict data: The dictionary to format
        :return: A formatted string
        """
        return pformat(data, indent=2, width=80)


    def create(self):

        origin_path, dest_path = self._build_paths()

        # The order of these inputs and the acceptable values
        # requires both santitation and a sanitarium
        params = self._sanitize_params()
        self._validate_params(params)

        
        if not self.relationship_table:
            try:
                # This is the ArcGIS Pro signature as of 20260218
                arcpy.management.CreateRelationshipClass(
                    origin_path
                   ,dest_path
                   ,self.fullpath(self.geodatabase)
                   ,params["relationship_type"]
                   ,params["forward_label"]
                   ,params["backward_label"]
                   ,self.message_direction
                   ,params["cardinality"]
                   ,params["attributed"]
                   ,params["origin_pk"]
                   ,params["origin_fk"]
                   ,params["dest_pk"]
                   ,params["dest_fk"]
                )

            except Exception as ex:
                msg = (
                    'CreateRelationshipClass failed.\n'
                    'Origin path: {0}\n'
                    'Destination path: {1}\n'
                    'Relationship class: {2}\n'
                    'Parameters: {3}\n'
                    'Error: {4}'.format(
                        origin_path,
                        dest_path,
                        self.fullpath(self.geodatabase),
                        params,
                        ex
                    )
                )

                raise RuntimeError(msg)
        else:
            relationship_table = os.path.join(self.geodatabase
                                             ,self.relationship_table)
            arcpy.management.TableToRelationshipClass(   
                origin_path
               ,dest_path
               ,self.fullpath(self.geodatabase)
               ,params["relationship_type"]
               ,params["forward_label"]
               ,params["backward_label"]
               ,self.message_direction
               ,params["cardinality"]
               ,relationship_table
               ,self.attribute_fields
               ,params["origin_pk"]
               ,params["origin_fk"]
               ,params["dest_pk"]
               ,params["dest_fk"]
            )        

    def delete(self):

        if self.exists():
            arcpy.management.Delete(self.fullpath(self.geodatabase))

    def hasglobalid(self):

        if (self.attributed != 'NONE') and self.fullpath(self.geodatabase):
            fields = {f.name.lower(): f for f in arcpy.ListFields(
                self.fullpath(self.geodatabase))}
            if 'globalid' not in fields:
                return False
            if fields['globalid'].type.lower() not in ('guid'
                                                      ,'globalid'
                                                      ,'uuid'):
                return False
            # ESRI managed GlobalID fields are required and non-nullable
            if (not fields['globalid'].required 
                and fields['globalid'].isNullable):
                return False
            return True
        else:
            return False

    def addglobalid(self):

        if (self.attributed != 'NONE') and self.fullpath(self.geodatabase):
            arcpy.management.AddGlobalIDs(self.fullpath(self.geodatabase))
        else:
            raise ValueError(
                'Cant add globalids to attibuted: {0}, {1}'.format(
                    self.attributed
                   ,self.fullpath(self.geodatabase))
            )

    def _build_paths(self):
        
        origin = os.path.join(self.geodatabase
                             ,self.origin_itempath)
        dest = os.path.join(self.geodatabase
                           ,self.destination_itempath)
        return origin, dest

    def _sanitize_params(self):
        return {
            "relationship_type": (self.relationship_type or 'SIMPLE').upper(),
            "cardinality": (self.cardinality or 'ONE_TO_MANY').upper(),
            "forward_label": self.forward_label or "",
            "backward_label": self.backward_label or "",
            "origin_pk": self.origin_primary_key or "",
            "origin_fk": self.origin_foreign_key or "",
            "dest_pk": self.destination_primary_key or "",  # REQUIRED
            "dest_fk": self.destination_foreign_key or "",
            "attributed" : (self.attributed or 'NONE').upper() 
        }

    def _validate_params(self
                        ,p):

        if p['relationship_type'] not in {'SIMPLE', 'COMPOSITE'}:
            raise ValueError(
                'Invalid relationship_type: {0}'.format(p['relationship_type'])
            )

        if p['cardinality'] not in {'ONE_TO_ONE', 'ONE_TO_MANY', 'MANY_TO_MANY'}:
            raise ValueError(
                'Invalid cardinality: {0}'.format(p['cardinality'])
            )

        if p['attributed'] not in {'NONE', 'ATTRIBUTED'}:
            raise ValueError(
                'Invalid attributed: {0}'.format(p['attributed'])
            )

        if p['attributed'] == 'ATTRIBUTED' and not p['origin_fk']:
            raise ValueError(
                'origin_foreign_key required for attributed relationships'
            )
