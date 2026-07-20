
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

* Ad hoc schema changes in a shared environment can break the environment and disrupt the work of others.
* Schema changes should go through review and source control. All changes should be deliberate and traceable.
* Separation of concerns: Database development should happen in sandbox schemas or similar isolated environments, not in the shared integration schema.
* Restricting access is a reliability measure, not a barrier to development.
* Ad hoc database changes lead to configuration drift. The risk is undocumented divergence from the baseline that we have documented and tracked in source control.

### Recommendations: In Order From Best Practice to Highest Risk

SDE.Default version should be made "Public" in development. This change supports editing workflows without granting unrestricted access to shared schemas.

1. Set up sandbox schema(s) for the development team.
2. Developers submit requests for schema changes to the shared integration schema and we implement them through the team-reviewed process. 
3. "Share the schema owner credentials for Version Management/GDB Maintenance tasks" with the understanding that the developers are responsible for maintaining the database migration baseline.
4. "Share the schema owner credentials for Version Management/GDB Maintenance tasks" and the developers are not resposible for remediating divergence. Someone else must clean it up.


