Identity and Access
* Database authentication vs OS authentication vs Application authentication
* Plans for creating and disabling users wherever users are managed
* Still using .sde connection files? Where are they stored and who manages?
* Should someone read up on ArcGIS Pro project templates? 

Authorization and Roles
* Edits will be performed from user schemas? Or will the application manage users and edits will be directed to shared application schemas?
* Database roles vs grants to individual users
* If roles, define the roles
* Who/How do we manage grants on datasets?
* Legacy CSCL had some sort of zany privilege model for individual columns or something? 
* Management of privilege boundaries on versions

Data Governance
* Reconcile/Post ownership and responsibilities
* Editor tracking (OS vs database options again)
* Any real auditing requirements we need to consider?
* Is there QA/QC and a cycle to fix errors?  Who runs QA/QC and who fixes?


Discussion

-	No user roles desired in new CSCL application.
-	Need to decide- figure out how to set up the user accounts
-	Oracle do no support LDAP set up. Need to set up a separate user accounts on DB side.
-	Can the application do authentication/Authentication on the front end and use a generic account to access DB.
-	Editor tracking can be done via Windows account
-	DB would know the windows users but can’t authenticate using windows account.
-	Clashes /conflicts on edits can be handled using versioning even though we may be using GeoDB versioning.
-	If managing at the application level: usernames can be stored in an xml files.
o	Currently db has user table.
o	Potentially we can maintain the user table in the DB to authenticate. And use system account for editing.
-	Need to decide process on how to manage versioning if we use system account (currently lower version merges with higher version). (Traditional vs branch versioning)
-	Since OTI has to publish data, it could slow down the editing process if we use branch version as we have a lot of validation. Not everything is supported using the same approach. Can look at Versioning 3.
    - The issue with branch versioning is not performance. Branch versioning requires a more complex architecture that we can’t support at OTI without additional resources. Traditional versioning, requiring a backend geodatabase and a front-end client, OTI can support.
-	Editor tracking – Windows or DB user to use for editor tracking. 
-	Right now we are not migrating the class extensions. Editor tracking was implemented in the class extensions in the legacy system
-	Need to resume the conversation with Tech Lead.
-	Having the authentication at the front end is better for security and user experience, and we can take advantage of OS based editor tracking feature offered by Arc Pro.
