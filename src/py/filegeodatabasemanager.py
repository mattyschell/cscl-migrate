import arcpy
import os
import stat
import shutil

class localgdb(object):

    def __init__(self
                ,filegdb):

        self.gdb      = filegdb
        self.name     = os.path.basename(self.gdb)
        self.path     = os.path.dirname(self.gdb)
        self.basename = self.name.split('.')[0]

    def create(self):

        arcpy.management.CreateFileGDB(self.path
                                      ,self.name)

    def remove_readonly(self
                       ,func
                       ,path
                       ,_):
        
        os.chmod(path, stat.S_IWRITE)
        func(path)

    def clean(self):

        if arcpy.Exists(self.gdb) and os.path.isdir(self.gdb):
            
            arcpy.Compact_management(self.gdb)
            shutil.rmtree(self.gdb, onerror=self.remove_readonly)   
