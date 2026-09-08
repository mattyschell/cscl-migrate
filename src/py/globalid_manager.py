import arcpy
import os


BASEGLOBALID_FIELD = 'BASEGLOBALID'
GLOBALID_FIELD = 'GLOBALID'
SUPPORTED_DATASET_TYPES = ('FeatureClass', 'Table', 'RelationshipClass')


def _file_geodatabase_path(dataset_path):
    path = os.path.dirname(dataset_path)
    while path and not path.lower().endswith('.gdb'):
        parent = os.path.dirname(path)
        if parent == path:
            raise ValueError(
                'Dataset is not in a file geodatabase: {0}'.format(
                    dataset_path
                )
            )
        path = parent
    return path


def preserve_globalid(dataset_path):
    """Copy a dataset's managed GLOBALID values to BASEGLOBALID."""

    description = arcpy.Describe(dataset_path)
    dataset_type = getattr(description, 'datasetType', None)
    if dataset_type not in SUPPORTED_DATASET_TYPES:
        raise ValueError(
            'GLOBALID preservation is not supported for {0}: {1}'.format(
                dataset_type,
                dataset_path
            )
        )

    fields = {
        field.name.upper(): field
        for field in arcpy.ListFields(dataset_path)
    }

    globalid = fields.get(GLOBALID_FIELD)
    if globalid is None:
        raise ValueError(
            'Dataset has no GLOBALID field: {0}'.format(dataset_path)
        )

    if globalid.type.lower() not in ('globalid', 'guid', 'uuid'):
        raise ValueError(
            'GLOBALID field has an unexpected type ({0}): {1}'.format(
                globalid.type,
                dataset_path
            )
        )

    if BASEGLOBALID_FIELD in fields:
        return 0

    arcpy.management.AddField(
        dataset_path,
        BASEGLOBALID_FIELD,
        'TEXT',
        field_length=38
    )

    editor = arcpy.da.Editor(_file_geodatabase_path(dataset_path))
    editor.startEditing(False, False)
    editor.startOperation()
    try:
        with arcpy.da.UpdateCursor(
            dataset_path,
            [BASEGLOBALID_FIELD, GLOBALID_FIELD]
        ) as rows:
            for row in rows:
                row[0] = row[1]
                rows.updateRow(row)
        editor.stopOperation()
        editor.stopEditing(True)
    except Exception:
        editor.abortOperation()
        editor.stopEditing(False)
        raise

    return 1
