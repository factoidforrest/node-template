# platform
### a Sails application


### Development setup steps

 install mongo and make sure it has no username or password on the database and trusts all localhost connections.  

npm installing everything.  just run npm install, everything is in the package.json so that should get your dependencies all set hopefully.

start the app with 'nodemon' when your terminal is in the root app directory with no arguments.  You might have to 'sudo npm install nodemon -g' before that will work..  To restart the server at any time, type rs into the terminal running nodemon and hit enter.  It will auto restart when any source code changes as well, which is the truly awesome part.  

#### Deployment
##### Env Variables

This application depends on a number of ENV variables to being set properly in order to deploy.
All values are lower case, all keys are upper case. 

NODE_ENV=production


This is a dual mode application which can serve either the API(backend), the assets(frontend), or both. 
Be sure to leave this variable unset(not just blank) when you want to serve both.
SERVER_MODE=(assets, api, unset)

DATABASE_URL= the mongo URL you wish to connect to in production.  
If unset, it will default to the development configuration on localhost.

WARN_EMAIL= The email which errors be sent to.  Leave unset to disable this feature.  