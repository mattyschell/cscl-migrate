import arcpy

if __name__ == "__main__":

    gdb = sys.argv[1]

    dataset_name = "CSCL"
    topology_name = "CSCL_Topology"

    
    arcpy.env.workspace = gdb

    #here

# Define full paths
dataset_path = gdb_path + "\\" + dataset_name
topology_path = dataset_path + "\\" + topology_name
centerline = dataset_path + "\\Centerline"
milepost = dataset_path + "\\MilePost"
reference_marker = dataset_path + "\\ReferenceMarker"
node = dataset_path + "\\Node"

# Create Topology
arcpy.CreateTopology_management(dataset_path, topology_name, "0.00328083333333333")  # tolerance in feet

# Add Feature Classes to Topology
arcpy.AddFeatureClassToTopology_management(topology_path, milepost, 1, 1)
arcpy.AddFeatureClassToTopology_management(topology_path, centerline, 1, 1)
arcpy.AddFeatureClassToTopology_management(topology_path, reference_marker, 1, 1)
arcpy.AddFeatureClassToTopology_management(topology_path, node, 1, 1)

# Add Topology Rules
arcpy.AddRuleToTopology_management(topology_path, "Must Be Covered By (Point-Line)", milepost, "", centerline, "")
arcpy.AddRuleToTopology_management(topology_path, "Must Be Covered By (Point-Line)", reference_marker, "", centerline, "")
arcpy.AddRuleToTopology_management(topology_path, "Must Be Covered By Endpoint Of (Point-Line)", node, "", centerline, "")
arcpy.AddRuleToTopology_management(topology_path, "Endpoint Must Be Covered By (Line-Point)", centerline, "", node, "")
arcpy.AddRuleToTopology_management(topology_path, "Must Not Overlap (Line)", centerline, "", "", "")
arcpy.AddRuleToTopology_management(topology_path, "Must Not Self-Intersect (Line)", centerline, "", "", "")
arcpy.AddRuleToTopology_management(topology_path, "Must Be Single Part (Line)", centerline, "", "", "")
arcpy.AddRuleToTopology_management(topology_path, "Must Not Intersect Or Touch Interior (Line)", centerline, "", "", "")
