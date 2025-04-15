

'Break vba glass in case of emergency
'this requires ArcCatalog 10.2 or similar


'=============================================================================
Private Sub removeAllClassExt()
	Dim pGxApp As IGxApplication
    Set pGxApp = Application
    Dim pWorkspace As IWorkspace
    
    'MsgBox pGxApp.SelectedObject.Category

    'limit to file geodatabases in cscl-migrate
    If (pGxApp.SelectedObject.Category = "File Geodatabase") Then
        
        'MsgBox pGxApp.SelectedObject.InternalObjectName        
        ' since the selected object is a file or SDE geodatabase, now we can set up and open the workspace
        Set pWorkspace = pGxApp.SelectedObject.InternalObjectName.Open
        
        If pWorkspace Is Nothing Then
            Exit Sub
        End If
        
        
        'Double check if you want to remove Class Extension for the selected object
        Dim answer As Integer
        answer = MsgBox("Are you sure you want to remove the Class Extensions from " & pWorkspace.PathName & " ?", vbYesNo + vbQuestion, "Remove Class Extensions?")
        
        If answer = vbYes Then
            'MsgBox "Will clear EX"
            
            ' this will work with feature dataset
            'PrintListOfDatasets pWorkspace, esriDTFeatureDataset
            
            'Process Feature dataset
            getFeatureClassAndDataset pWorkspace, esriDTFeatureDataset
            
            'Process Feature Classes
            getFeatureClassAndDataset pWorkspace, esriDTFeatureClass
  
            'Process Feature tables
            getFeatureClassAndDataset pWorkspace, esriDTTable
            
            MsgBox "Class Extensions removed from the database"
            
        Else
            MsgBox "No Class Extension will be removed!!!"
            Exit Sub
        End If
    Else
        'MsgBox pGxApp.SelectedObject.Category
        MsgBox "You have selected " & pGxApp.SelectedObject.Category & "." & vbNewLine & "Please select a valid File/Personal Geodatabase or SDE connection file !", vbInformation, "Wrong Selection!"
        Exit Sub
    End If 
End Sub


'======================================================================================================  
' Get FeatureClass and Dataset from Workspace
Private Sub getFeatureClassAndDataset(pWorkspace As IWorkspace, pDatatype As esriDatasetType)
'MsgBox "This will process feature dataset "
  
  'Decleare variables
    Dim pDatasetName As IDatasetName
    Dim pEnumDatasetName As IEnumDatasetName
    Dim pEnumDatasetFromFDset As IEnumDataset
    Dim pDataset As IDataset
    Dim pFeatureDataset As IFeatureDataset
    Dim pName As IName
  
    ' Get access to members that enumerate through Dataset Names.
    Set pEnumDatasetName = pWorkspace.DatasetNames(pDatatype)
    ' get the data set based on esriDatasetType
    Set pDatasetName = pEnumDatasetName.Next
    
    
    ' Loop the pDatasetName until it is ture ( not NULL)
    While Not pDatasetName Is Nothing
         
         'if it is a  Feature Dataset
         If pDatatype = esriDTFeatureDataset Then
            'this is Feature Dataset. Spacial process required
            Set pName = pDatasetName
            Set pFeatureDataset = pName.Open
            Set pEnumDatasetFromFDset = pFeatureDataset.Subsets
            Set pDataset = pEnumDatasetFromFDset.Next
            
            While Not pDataset Is Nothing
                'we are only interested in feature classes and not other types of data (relationships, topologies, gn, etc)
                If pDataset.Type = esriDTFeatureClass Then
                    'since this is only a feature class
                    Dim fcName1 As String
                    fcName1 = pDataset.Name 'get the feature class Name
                    
                    'Call the function to REMOVE the Class Extention
                    'getFeatureClassFromWP pWorkspace, fcName1, pDatatype
                    '===================================================
                    removeClassExtention pWorkspace, fcName1, pDatatype
                End If
                ' go to next feature class if Feature Dataset has multiple feature class
                Set pDataset = pEnumDatasetFromFDset.Next
            Wend
            ' done with feature dataset
            
        'if it is not a Feature Dataset - feature class or tables.
         Else
            'this section process feature class or feature tables
            Dim fcName As String
            fcName = pDatasetName.Name 'get the feature class Name
            
            'Call the function to REMOVE the Class Extention
            'getFeatureClassFromWP pWorkspace, fcName, pDatatype
            '===================================================
            removeClassExtention pWorkspace, fcName, pDatatype
        End If

    ' contine the loop
    Set pDatasetName = pEnumDatasetName.Next
    Wend
  
End Sub


'======================================================================================================
'this function will take workspace, feature name or table name and data types and remove class extension
Private Sub removeClassExtention(pWorkspace As IWorkspace, featureName As String, pDatatype As esriDatasetType)
   
    ' to get access to opren workspace to open feature class/table
    Dim pFeatws As IFeatureWorkspace
    Set pFeatws = pWorkspace
    
    Dim pClassSchemaEdit As IClassSchemaEdit
    
    'based on esriDatasetType - open a table or feature class
    If pDatatype = esriDTTable Then
        Dim pFeatcls As ITable
        Set pFeatcls = pFeatws.OpenTable(featureName)
        
            If Not pFeatcls.EXTCLSID Is Nothing Then
                Set pClassSchemaEdit = pFeatcls
				'Call remove function to remove CL
                remove pClassSchemaEdit, featureName
            End If
        
    Else
        Dim pFeatcls1 As IFeatureClass
        Set pFeatcls1 = pFeatws.OpenFeatureClass(featureName)
            If Not pFeatcls1.EXTCLSID Is Nothing Then
                Set pClassSchemaEdit = pFeatcls1
                remove pClassSchemaEdit, featureName
            'Else
                'MsgBox "Class Extension does not exist for : " & featureName
                'noCX = noCX & featureName
            End If                
    End If 
End Sub

'======================================================================================================
Private Sub remove(pClassSchemaEdit As IClassSchemaEdit, featureName As String)

    Dim puid As UID
    Set puid = Nothing
    
    Dim pSchemaLock As ISchemaLock
    Set pSchemaLock = pClassSchemaEdit
    
    pSchemaLock.ChangeSchemaLock esriExclusiveSchemaLock
    pClassSchemaEdit.AlterClassExtensionCLSID puid, Nothing
    pSchemaLock.ChangeSchemaLock esriSharedSchemaLock    
    'MsgBox "Class extension removed for " & featureName
End Sub


'======================================================================================================
'THIS is Old cose. This function can remove CL from since feature class/table 
' and test if the FC or FT has any class extensions.
'======================================================================================================
Private Sub checkCL()

    Dim pGxApp As IGxApplication
    Set pGxApp = Application
    
    Dim pGxObject As IGxObject
    If (pGxObject Is Nothing) Then
        Set pGxObject = pGxApp.SelectedObject
    End If
    
    If Not (TypeOf pGxObject Is IGxDataset) Then Exit Sub
    
    Dim pGxDataset As IGxDataset
    Set pGxDataset = pGxObject ' QI
    
    If Not (TypeOf pGxDataset.Dataset Is IClass) Then Exit Sub
    
    Dim pClass As IClass
    Set pClass = pGxDataset.Dataset
    
    Dim strGUID As String
    strGUID = InputBox("Enter GUID", "Set class extension for " & pGxObject.Name)
    If Len(strGUID) <> 38 And UCase(strGUID) <> "NOTHING" Then
        ' Show the current extension
        Dim strCurrent As String
        If pClass.EXTCLSID Is Nothing Then
            strCurrent = "Current class extension is nothing"
        Else
            strCurrent = "Current class extension is: " & pClass.EXTCLSID
        End If
        MsgBox "No valid GUID entered." & vbNewLine & strCurrent
        Exit Sub
    End If
    
    
    Dim puid As New UID
    If UCase(strGUID) = "NOTHING" Then
        Set puid = Nothing
    Else
        puid.Value = strGUID
    End If
    
    Dim pClassSchemaEdit As IClassSchemaEdit
    Set pClassSchemaEdit = pClass
    Dim pSchemaLock As ISchemaLock
    Set pSchemaLock = pClassSchemaEdit
    pSchemaLock.ChangeSchemaLock esriExclusiveSchemaLock
    pClassSchemaEdit.AlterClassExtensionCLSID puid, Nothing
    pSchemaLock.ChangeSchemaLock esriSharedSchemaLock
    
    MsgBox "Class extension changed for " & pGxObject.Name
End Sub