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

This application has multiple roles it is expected to serve such as daily, staging, and production(and of course development, which does not need to be set).  To configure this set:

SERVER_ROLE=(production,staging,daily)

DATABASE_URI= the mongo URI you wish to connect to in production.  
If unset, it will default to the development configuration on localhost.

WARN_EMAIL= The email which errors be sent to.  Leave unset to disable this feature.  

######TCC API configuration variables

TCC: process.env.TCC ||  'http://64.73.249.146/Partner/ProcessJson',
clientID: process.env.CLIENTID || 73,

######For remote pushing to the server
First add this guy to your local repo
git remote add daily ssh://deployer@23.20.9.88/home/deployer/repos/mobile-gift-card-platform.git

Then after you make commits and push to the branch you can then do this:
git push daily origin/development
This will push it to the server in the daily environment providing your public cert is installed on the server.
