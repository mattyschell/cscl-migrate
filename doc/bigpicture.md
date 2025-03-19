# BIG PICTURE

Frame for big picture picture:

| COOL CAT LIKES BIG PICTURES   |
|---|
|   /\\_/\ <br> ( o.o )  <br>  > ^ < |



### Not big picture

### Questions

1. Is our initial use of this workflow to set up a dev environment for CSCL modernization work to begin?  Or should we think final production-ey thoughts while looking at it?
2. How many times do we think we will execute this workflow?
3. Is the source "Oracle + GDB" always CSCL production?
4. Why is a full compress required on the source geodatabase?
5. Why do the replicas need to be disconnected?  Is this for the full compress or something more?
6. Is the "FGDB" at the bottom of the diagram the cscl file geodatabase replica? Or is this something new? ("Remove Class Ext" = not replica, right?)
7. Why "Copy _H tables" directly to the "New Oracle + GDB"? Could they transit through the same intermediate file geodatabase or some other file geodatabase?
8. Do the copied _H tables also require the tolerance/resolution adjustment? If we are unsure of this requirement, what are the downsides to adjusting tolerance/resolution of the copied _H tables to be safe.


### Comments

1. To simplify our discussion I suggest we use ESRI approach 2 ("registration update") for the archive migration.  Approach 1 is ourS backup option until further notice.
2. The default storage type for ESRI Enterprise Geodatabases is SDE.ST_GEOMETRY. So it's not strictly a "task" or "change."
3. This may be too low level for this diagram but perhaps consider adding a database setup task.  
    3a. Create users
    3b. Create and grant roles
    3c. After data imports perform grants on data to roles
4. If we plan on repeating this workflow more than once from the same source to target then some of the tasks are "one time only" and some are repeated each time. I think it would be helpful to indicate which is which.
5. Similarly it might be helpful to indicate where there are one-way gates in the workflow.  For example after "Copy _H tables" and "Copy Base tables to FGDB" the source "Oracle + GDB" can be restored for day-to-day work. (what are these restoration steps btw?)
6. For the archive-related tasks on the "New Oracle + GDB" consider removing the gory details (which are in flux) from your high-level diagram and refer instead to https://github.com/mattyschell/cscl-refresh/blob/main/doc/archive-migration.md#approach-2-registration-update