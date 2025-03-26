# BIG PICTURE


![big picture](bigpicture.png)


### Not big picture

### Questions 

1. Is our initial use of this workflow to set up a dev environment for CSCL modernization work to begin?  Or should we think final production-ey thoughts while looking at it?

    Both. Our goal is the final production migration. But we wish to create a workflow for repeated migrations to non-prod environments.

2. How many times do we think we will execute this workflow?

    Many. Yes it should be scripted or automated to a reasonable extent.

3. Is the source "Oracle + GDB" always CSCL production?

    No. Legacy development is where we will start.

4. Why is a full compress required on the source geodatabase?

    Not sure on this.  We just like it it makes us feel good.

5. Why do the replicas need to be disconnected?  Is this for the full compress or something more?

    Not sure on this.

6. Is the "FGDB" at the bottom of the diagram the cscl file geodatabase replica? Or is this something new? ("Remove Class Ext" = not replica, right?)


    It is a new file geodatabase created  in this workflow.

7. Why "Copy _H tables" directly to the "New Oracle + GDB"? Could they transit through the same intermediate file geodatabase or some other file geodatabase?

    We are proposing a workflow where we plunk the base tables into the target environment and then enable archiving.  Then truncate the target _H tables and reload from the source _H tables.  This ensures that columns and data types on the target _H tables are created in the modernized environment.   

8. Do the copied _H tables also require the tolerance/resolution adjustment? If we are unsure of this requirement, what are the downsides to adjusting tolerance/resolution of the copied _H tables to be safe.

    Signs point to yes.  When unhiding _H tables on the source we do see bad tolerance/resolution values.  

### Comments

1. To simplify our discussion I suggest we use ESRI approach 2 ("registration update") for the archive migration.  Approach 1 is ourS backup option until further notice.

    Nope.  We now have an approach 3!

2. The default storage type for ESRI Enterprise Geodatabases is SDE.ST_GEOMETRY. So it's not strictly a "task" or "change."

    We should also investigate the other parts of the keywords 

3. This may be too low level for this diagram but perhaps consider adding a database setup task.  This might include create users, create and grant roles, and performing grants to roles.

    No. Our goal here is only to migrate the data. Specifications for users, roles, versions, and so on will come from the architect decisions at City Planning.

4. If we plan on repeating this workflow more than once from the same source to target then some of the tasks are "one time only" and some are repeated each time. I think it would be helpful to indicate which is which.

    One time only should mostly be out of scope for this exercise.

5. Similarly it might be helpful to indicate where there are one-way gates in the workflow.  For example after "Copy _H tables" and "Copy Base tables to FGDB" the source "Oracle + GDB" can be restored for day-to-day work. (what are these restoration steps btw?)

    This will depend on the final migration workflow and may be NA.

