mongo-jira
==========

Simple Jira command line tool

This is a stub for a set of very simple command lines tools to access Jira tickets through the
REST api

## Installation

Install it yourself as:

    $ gem install mongo-jira

## Usage

### Initial configuration

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


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
