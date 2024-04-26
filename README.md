# JIRA API Gem

[![Code Climate](https://codeclimate.com/github/sumoheavy/jira-ruby.svg)](https://codeclimate.com/github/sumoheavy/jira-ruby)
[![Build Status](https://github.com/sumoheavy/jira-ruby/actions/workflows/CI.yml/badge.svg)](https://github.com/sumoheavy/jira-ruby/actions/workflows/CI.yml)

This gem provides access to the Atlassian JIRA REST API.

## Slack

Join our Slack channel! You can find us [here](https://jira-ruby-slackin.herokuapp.com/)

## Example usage

# Jira Ruby API - Sample Usage

This sample usage demonstrates how you can interact with JIRA's API using the [jira-ruby gem](https://github.com/sumoheavy/jira-ruby).

### Dependencies

Before running, install the `jira-ruby` gem:

```shell
gem install jira-ruby
```

### Sample Usage
Connect to JIRA
Firstly, establish a connection with your JIRA instance by providing a few configuration parameters:
There are other ways to connect to JIRA listed below |  [Personal Access Token](#configuring-jira-to-use-personal-access-tokens-auth)
- ﻿private_key_file: The path to your RSA private key file.
- ﻿consumer_key: Your consumer key.
- site: The URL of your JIRA instance.

```ruby
options = {
  :private_key_file => "rsakey.pem",
  :context_path     => '',
  :consumer_key     => 'your_consumer_key',
  :site             => 'your_jira_instance_url'
}

client = JIRA::Client.new(options)
```

### Retrieve and Display Projects

After establishing the connection, you can fetch all projects and display their key and name:
```ruby
projects = client.Project.all

projects.each do |project|
  puts "Project -> key: #{project.key}, name: #{project.name}"
end
```

### Handling Fields by Name
The ﻿jira-ruby gem allows you to refer to fields by their custom names rather than identifiers. Make sure to map fields before using them:

```ruby
client.Field.map_fields

old_way = issue.customfield_12345

# Note: The methods mapped here adopt a unique style combining PascalCase and snake_case conventions.
new_way = issue.Special_Field
```

### JQL Queries
To find issues based on specific criteria, you can use JIRA Query Language (JQL):

```ruby
client.Issue.jql(a_normal_jql_search, fields:[:description, :summary, :Special_field, :created])
```

### Several actions can be performed on the ﻿Issue object such as create, update, transition, delete, etc:
### Creating an Issue
```ruby
issue = client.Issue.build
labels = ['label1', 'label2']
issue.save({
  "fields" => {
    "summary" => "blarg from in example.rb",
    "project" => {"key" => "SAMPLEPROJECT"},
    "issuetype" => {"id" => "3"},
    "labels" => labels,
    "priority" => {"id" => "1"}
  }
})
```

### Updating/Transitioning an Issue
```ruby
issue = client.Issue.find("10002")
issue.save({"fields"=>{"summary"=>"EVEN MOOOOOOARRR NINJAAAA!"}})

issue_transition = issue.transitions.build
issue_transition.save!('transition' => {'id' => transition_id})
```

### Deleting an Issue
```ruby
issue = client.Issue.find('SAMPLEPROJECT-2')
issue.delete
```

### Other Capabilities
Apart from the operations listed above, this API wrapper supports several other capabilities like:
	•	Searching for a user
	•	Retrieving an issue's watchers
	•	Changing the assignee of an issue
	•	Adding attachments and comments to issues
	•	Managing issue links and much more.

Not all examples are shown in this README; refer to the complete script example for a full overview of the capabilities supported by this API wrapper.

## Links to JIRA REST API documentation

* [Overview](https://developer.atlassian.com/display/JIRADEV/JIRA+REST+APIs)

* [Reference](http://docs.atlassian.com/jira/REST/latest/)

## Running tests

Before running tests, you will need a public certificate generated.

```shell
rake jira:generate_public_cert
```

## Setting up the JIRA SDK

On Mac OS,

* Follow the instructions under "Mac OSX Installer" here: https://developer.atlassian.com/server/framework/atlassian-sdk/install-the-atlassian-sdk-on-a-linux-or-mac-system
* From within the archive directory, run:

```shell
./bin/atlas-run-standalone --product jira
```

Once this is running, you should be able to connect to
http://localhost:2990/ and login to the JIRA admin system using `admin:admin`

You'll need to create a dummy project and probably some issues to test using
this library.

## Configuring JIRA to use OAuth

From the JIRA API tutorial

> The first step is to register a new consumer in JIRA. This is done through
> the Application Links administration screens in JIRA. Create a new
> Application Link.
> [Administration/Plugins/Application Links](http://localhost:2990/jira/plugins/servlet/applinks/listApplicationLinks)
>
> When creating the Application Link use a placeholder URL or the correct URL
> to your client (e.g. `http://localhost:3000`), if your client can be reached
> via HTTP and choose the Generic Application type. After this Application Link
> has been created, edit the configuration and go to the incoming
> authentication configuration screen and select OAuth. Enter in this the
> public key and the consumer key which your client will use when making
> requests to JIRA.

This public key and consumer key will need to be generated by the Gem user, using OpenSSL
or similar to generate the public key and the provided rake task to generate the consumer
key.

> After you have entered all the information click OK and ensure OAuth authentication is
> enabled.

For two legged oauth in server mode only, not in cloud based JIRA, make sure to `Allow 2-Legged OAuth`

## Configuring JIRA to use HTTP Basic Auth

Follow the same steps described above to set up a new Application Link in JIRA,
however there is no need to set up any "incoming authentication" as this
defaults to HTTP Basic Auth.

## Configuring JIRA to use Cookie-Based Auth

Jira supports cookie based authentication whereby user credentials are passed
to JIRA via a JIRA REST API call.  This call returns a session cookie which must
then be sent to all following JIRA REST API calls.

To enable cookie based authentication, set `:auth_type` to `:cookie`,
set `:use_cookies` to `true` and set `:username` and `:password` accordingly.

```ruby
require 'jira-ruby'

options = {
  :username           => 'username',
  :password           => 'pass1234',
  :site               => 'http://mydomain.atlassian.net:443/',
  :context_path       => '',
  :auth_type          => :cookie,  # Set cookie based authentication
  :use_cookies        => true,     # Send cookies with each request
  :additional_cookies => ['AUTH=vV7uzixt0SScJKg7'] # Optional cookies to send
                                                   # with each request
}

client = JIRA::Client.new(options)

project = client.Project.find('SAMPLEPROJECT')

project.issues.each do |issue|
  puts "#{issue.id} - #{issue.summary}"
end
```

Some authentication schemes might require additional cookies to be sent with
each request.  Cookies added to the `:additional_cookies` option will be added
to each request.  This option should be an array of strings representing each
cookie to add to the request.

Some authentication schemes that require additional cookies ignore the username
and password sent in the JIRA REST API call.  For those use cases, `:username`
and `:password` may be omitted from `options`.

## Configuring JIRA to use Personal Access Tokens Auth
If your JIRA system is configured to support Personal Access Token authorization, minor modifications are needed in how credentials are communicated to the server.  Specifically, the paremeters `:username` and `:password` are not needed.  Also, the parameter `:default_headers` is needed to contain the api_token, which can be obtained following the official documentation from [Atlassian](https://confluence.atlassian.com/enterprise/using-personal-access-tokens-1026032365.html).  Please note that the Personal Access Token can only be used as it is. If it is encoded (with base64 or any other encoding method) then the token will not work correctly and authentication will fail.

```ruby
require 'jira-ruby'

# NOTE: the token should not be encoded
api_token = API_TOKEN_OBTAINED_FROM_JIRA_UI

options = {
  :site               => 'http://mydomain.atlassian.net:443/',
  :context_path       => '',
  :username           => '<the email you sign-in to Jira>',
  :password           => api_token,
  :auth_type          => :basic
}

client = JIRA::Client.new(options)

project = client.Project.find('SAMPLEPROJECT')

project.issues.each do |issue|
  puts "#{issue.id} - #{issue.summary}"
end
```
## Using the API Gem in a command line application

Using HTTP Basic Authentication, configure and connect a client to your instance
of JIRA.

Note: If your Jira install is hosted on [atlassian.net](atlassian.net), it will have no context
path by default. If you're having issues connecting, try setting context_path
to an empty string in the options hash.

```ruby
require 'rubygems'
require 'pp'
require 'jira-ruby'

# Consider the use of :use_ssl and :ssl_verify_mode options if running locally
# for tests.

# NOTE basic auth no longer works with Jira, you must generate an API token, to do so you must have jira instance access rights. You can generate a token here: https://id.atlassian.com/manage/api-tokens

# You will see JIRA::HTTPError (JIRA::HTTPError) if you attempt to use basic auth with your user's password

username = "myremoteuser"
api_token = "myApiToken"

options = {
            :username => username,
            :password => api_token,
            :site     => 'http://localhost:8080/', # or 'https://<your_subdomain>.atlassian.net/'
            :context_path => '/myjira', # often blank
            :auth_type => :basic,
            :read_timeout => 120
          }

client = JIRA::Client.new(options)

# Show all projects
projects = client.Project.all

projects.each do |project|
  puts "Project -> key: #{project.key}, name: #{project.name}"
end
```

## Using the API Gem in your Rails application

Using oauth, the gem requires the consumer key and public certificate file (which
are generated in their respective rake tasks) to initialize an access token for
using the JIRA API.

Note that currently the rake task which generates the public certificate
requires OpenSSL to be installed on the machine.

Below is an example for setting up a rails application for OAuth authorization.

Ensure the JIRA gem is loaded correctly

```ruby
# Gemfile
...
gem 'jira-ruby', :require => 'jira-ruby'
...
```

Add common methods to your application controller and ensure access token
errors are handled gracefully

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from JIRA::OauthClient::UninitializedAccessTokenError do
    redirect_to new_jira_session_url
  end

  private

  def get_jira_client

    # add any extra configuration options for your instance of JIRA,
    # e.g. :use_ssl, :ssl_verify_mode, :context_path, :site
    options = {
      :private_key_file => "rsakey.pem",
      :consumer_key => 'test'
    }

    @jira_client = JIRA::Client.new(options)

    # Add AccessToken if authorised previously.
    if session[:jira_auth]
      @jira_client.set_access_token(
        session[:jira_auth]['access_token'],
        session[:jira_auth]['access_key']
      )
    end
  end
end
```

Create a controller for handling the OAuth conversation.

```ruby
# app/controllers/jira_sessions_controller.rb
class JiraSessionsController < ApplicationController

  before_filter :get_jira_client

  def new
    callback_url = 'http://callback'
    request_token = @jira_client.request_token(oauth_callback: callback_url)
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret

    redirect_to request_token.authorize_url
  end

  def authorize
    request_token = @jira_client.set_request_token(
      session[:request_token], session[:request_secret]
    )
    access_token = @jira_client.init_access_token(
      :oauth_verifier => params[:oauth_verifier]
    )

    session[:jira_auth] = {
      :access_token => access_token.token,
      :access_key => access_token.secret
    }

    session.delete(:request_token)
    session.delete(:request_secret)

    redirect_to projects_path
  end

  def destroy
    session.data.delete(:jira_auth)
  end
end
```

Create your own controllers for the JIRA resources you wish to access.

```ruby
# app/controllers/issues_controller.rb
class IssuesController < ApplicationController
  before_filter :get_jira_client
  def index
    @issues = @jira_client.Issue.all
  end

  def show
    @issue = @jira_client.Issue.find(params[:id])
  end
end
```

## Using the API Gem in your Sinatra application

Here's the same example as a Sinatra application:

```ruby
require 'jira-ruby'
class App < Sinatra::Base
  enable :sessions

  # This section gets called before every request. Here, we set up the
  # OAuth consumer details including the consumer key, private key,
  # site uri, and the request token, access token, and authorize paths
  before do
    options = {
      :site               => 'http://localhost:2990/',
      :context_path       => '/jira',
      :signature_method   => 'RSA-SHA1',
      :request_token_path => "/plugins/servlet/oauth/request-token",
      :authorize_path     => "/plugins/servlet/oauth/authorize",
      :access_token_path  => "/plugins/servlet/oauth/access-token",
      :private_key_file   => "rsakey.pem",
      :rest_base_path     => "/rest/api/2",
      :consumer_key       => "jira-ruby-example"
    }

    @jira_client = JIRA::Client.new(options)
    @jira_client.consumer.http.set_debug_output($stderr)

    # Add AccessToken if authorised previously.
    if session[:jira_auth]
      @jira_client.set_access_token(
        session[:jira_auth][:access_token],
        session[:jira_auth][:access_key]
      )
    end
  end


  # Starting point: http://<yourserver>/
  # This will serve up a login link if you're not logged in. If you are, it'll show some user info and a
  # signout link
  get '/' do
    if !session[:jira_auth]
      # not logged in
      <<-eos
        <h1>jira-ruby (JIRA 5 Ruby Gem) demo </h1>You're not signed in. Why don't you
        <a href=/signin>sign in</a> first.
      eos
    else
      #logged in
      @issues = @jira_client.Issue.all

      # HTTP response inlined with bind data below...
      <<-eos
        You're now signed in. There #{@issues.count == 1 ? "is" : "are"} #{@issues.count}
        issue#{@issues.count == 1 ? "" : "s"} in this JIRA instance. <a href='/signout'>Signout</a>
      eos
    end
  end

  # http://<yourserver>/signin
  # Initiates the OAuth dance by first requesting a token then redirecting to
  # http://<yourserver>/auth to get the @access_token
  get '/signin' do
    callback_url = "#{request.base_url}/callback"
    request_token = @jira_client.request_token(oauth_callback: callback_url)
    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret

    redirect request_token.authorize_url
  end

  # http://<yourserver>/callback
  # Retrieves the @access_token then stores it inside a session cookie. In a real app,
  # you'll want to persist the token in a datastore associated with the user.
  get "/callback" do
    request_token = @jira_client.set_request_token(
      session[:request_token], session[:request_secret]
    )
    access_token = @jira_client.init_access_token(
      :oauth_verifier => params[:oauth_verifier]
    )

    session[:jira_auth] = {
      :access_token => access_token.token,
      :access_key => access_token.secret
    }

    session.delete(:request_token)
    session.delete(:request_secret)

    redirect "/"
  end

  # http://<yourserver>/signout
  # Expires the session
  get "/signout" do
    session.delete(:jira_auth)
    redirect "/"
  end
end
```

## Using the API Gem in a 2 legged context

Here's an example on how to use 2 legged OAuth:
```ruby
require 'rubygems'
require 'pp'
require 'jira-ruby'

options = {
            :site               => 'http://localhost:2990/',
            :context_path       => '/jira',
            :signature_method   => 'RSA-SHA1',
            :private_key_file   => "rsakey.pem",
            :rest_base_path     => "/rest/api/2",
            :auth_type => :oauth_2legged,
            :consumer_key       => "jira-ruby-example"
          }

client = JIRA::Client.new(options)

client.set_access_token("","")

# Show all projects
projects = client.Project.all

projects.each do |project|
  puts "Project -> key: #{project.key}, name: #{project.name}"
end
```
