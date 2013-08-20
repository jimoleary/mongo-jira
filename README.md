mongo-jira
==========

Simple Jira command line tool

This is a stub for a set of very simple command lines tools to access Jira tickets through the
REST api

## Initial configuration

Create a file called **.mongo-jira.json** in your home dir  (alternatively use the -c flag to set different location). Add the following :

    {
      "username": "jim.oleary@10gen.com",
      "password": "Base64EncodedPassword==",
      "site": "https://jira.mongodb.org",
      "auth_type": "basic",
      "context_path": ""
    }

If you omit the password, then you will be asked for one. 

Change **<your username>** and **<your password>** ;-)

Execute the following command, if your config is correct you should see all your Jira projects:

    jira test