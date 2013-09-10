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
      "username": "jim.oleary@mongodb.com",
      "password": "Base64EncodedPassword==",
      "site": "https://jira.mongodb.org",
      "auth_type": "basic",
      "context_path": ""
    }

If you omit the password, then you will be asked for one. 

Change **<your username>** and **<your password>** ;-)

Execute the following command, if your config is correct you should see all your Jira projects:

    jira test

### Running the tests

In order to run the tests you will need to make sure that the dev dependencies are install.

   $> gem install --development mongo-jira

OR 

   $> rake install
   $> gem install --development pkg/mongo-jira-<version>.gem

Then you can run the tests with :

   $> rake spec
   Run options: --seed 12422

   # Running tests:

   ...................................................................................................................

   Finished tests in 0.177659s, 647.3075 tests/s, 1030.0632 assertions/s.

   115 tests, 183 assertions, 0 failures, 0 errors, 0 skips

TODO : add more tests 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. test your feature, see the spec directory 
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

