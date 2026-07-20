
## From the Tech Lead

### Current Set up
* Lack of Schema Ownership
* Cannot perform Version Management.
* Cannot perform Geodatabase Administration(Compress/Analyze)
* Latency in editing workflows/Post-Reconcile to Base[DEFAULT]
* Development delay due to coordination with DBA/OTI

### Recommended approach:
* Share the schema owner credentials for Version Management/GDB Maintenance tasks
* Helps expedite development/Test Cycle

## Initial Response and Recommendations

We should think of the CSCL schema in the development environment as a shared integration schema. 

### Shared Integration Schema

* Ad hoc schema changes in a shared enviornment can break the environment and disrupt the work of others.
* Schema changes should go through review and source control. All changes should be deliberate and traceable.
* Separation of concerns: Database development should happen in sandbox schemas or similar environments, not in the shared integration schema.
* Restricting access is a reliability measure, not a barrier to development.
* Ad hoc database changes lead to configuration drift. The risk is creation of undocumented drift from the baseline that we have documented and tracked in source control.

### Recommendations: In Order From Best Practice to YOLO Development

SDE.Default version should be made "Public" in development. This is data, not data definition. 

1. Set up sandbox schema(s) for the development team.
2. Developers file issues for schema changes in the shared integration schema and we implement them as a team. 
3. "Share the schema owner credentials for Version Management/GDB Maintenance tasks" with the understanding that the developers own the database migration baseline.  
4. "Share the schema owner credentials for Version Management/GDB Maintenance tasks" and the developers do not own divergence/issues from the baseline. Someone else must clean it up.


