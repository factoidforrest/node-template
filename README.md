# platform
### a Sails application


#### Deployment
##### Env Variables

This application depends on a number of ENV variables to being set properply in order to deploy.
All values are lower case, all keys are upper case. 

NODE_ENV=production


This is a dual mode application which can serve either the API(backend), the assets(frontend), or both. 
Be sure to leave this variable unset(not just blank) when you want to serve both.
SERVER_MODE=(assets, api, unset)

DATABASE_URL= the mongo URL you wish to connect to in production.  
If unset, it will default to the development configuration on localhost.

WARN_EMAIL= The email which errors be sent to.  Leave unset to disable this feature.  