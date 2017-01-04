# Futest flexible testing for Ruby

Test driven development has never been easier. If you like to write scripts instead of tests, and not worry about how your testing framework works, then Futest will give you exactly what you need.

### Installation
```
gem install futest
```
or add to Gemfile. In your tests include the line
```ruby
include Futest::Helpers
```
and you're good to go.

### Settings
```ruby
# The command to run when you use 'show'
# The default is for MacOs. The -g flag opens the page in the background.
Futest.show = 'open -g'

# Mode, default is development
Futest.mode = RACK['ENV'] || 'development'

# Debug
Futest.debug = false
```

### Commands
- **test:** Takes a description and optional setup methods, then prints the description and current line number.
- **stop:** Stop test and print error along with line number.
- **is:** Checks if something is true and stops if it isn't. See the usage section below.
- **pull:** Pulls a URL and expose varibles with info you can use.
- **show:** Shows the body from the last pull in your web browser.
- **err:** Print formatted error message and stops the test.

### Usage
For a real-world example with a test runner ready, have a look at [the tests for Futest.](https://github.com/fugroup/futest/tree/master/test)
```ruby
# Require futest if not using Bundler
require 'futest'

# Include the Futest helpers in your test runner
include Futest::Helpers

# Run the tests from your app root directory
ruby test/run.rb

# Auto-test with Rerun, Guard or other libraries
Rerun: https://github.com/alexch/rerun
gem 'rerun'
gem 'rb-fsevent'
gem 'terminal-notifier'

# Example command for Rerun, can be added to a shell alias
bundle exec rerun --dir .,config --pattern '**/*.{rb,ru,yml}' -- ruby test/run.rb

# Use begin to have formatted output on error
begin

  # Print string in green
  test 'Testing Heliocentric Model'

  # Optionally pass setup methods to run as symbols
  # define setup methods
  def setup; @hello = 'Welcome to the curve.'; end

  def setup_user
    @user = User.first
  end

  test 'Reality', :setup, :setup_user
  is @user, :a? => User
  is @hello, 'Welcome to the flatness.'

  # :eq is default, can be omitted
  is 'horizon', 'curved'
  is 1, 1
  is 1, :eq => 1
  is 1, :gt => 0
  is 1, :lt => 2
  is 1, :a? => Integer

  # 1 argument is also allowed
  is 'everything' == 'stories'

  # Use stop to end the test run
  stop "Can't process" if :earth == 'flat'

  # Pass the validated model object to print the error messages
  @user = User.first
  @user.name = "Truth"

  stop "Can't believe user", user unless user.save

  # Here are the tests that show how it works
  # There options are:
  # :a?, :eq, :lt, :lte, :gt, :gte, :in, :nin, :has
  s = 'hello'
  is s, 'hello'
  is s == 'hello', true
  is s != 'hello', false
  is s.start_with?('h'), true
  is nil, NilClass

  is 1, 1
  is 1, Integer
  is 1, :a? => Integer
  is 1, :eq => 1
  is 1, :lt => 2
  is 1, :lte => 2
  is 2, :lte => 2
  is 2, :gte => 2
  is 3, :gte => 2
  is 6, :gte => 2
  is 1, :in => [1,2,3]
  is 5, :nin => [1,2,3]
  is({:test => 1}, :has => :test)

  # Set up the @host variable to use pull if you want to test requests
  # The pull format is pull(method = :get, path, params, headers)
  # Default is :get, but :post, :delete, :update, :patch are supported.

  # You can set the @host globally with $host in stead
  # Optionally specify a @base variable to pre-add a path after the @host
  @base = '/login' # Optional
  @host = 'http://waveorb.com' # Required

  # URL will be @host + @base, http://waveorb.com/login in this case
  pull '/login'
  pull '/login', :duration => 'long'
  pull '/login', {:duration => 'long'}, :pjax => '1'

  # The pull command exposes these variables for use with tests
  is @host, 'http://waveorb.com'
  is @page, :a? => String
  is @code, 200
  is @cookies, :a? => Hash
  is @headers, :a? => Hash
  is @raw, :a? => Hash
  is @history, :a? => Array
  is @body, :a? => String


  # # # # # # # # # # # #
  # Example test with login

  # Post the email and password to the login resource
  def login
    pull :post, '/login', :email => 'vidar@fugroup.net', :password => 'test'
  end

  # Print the name of the test, and run the login
  # Cookies will be sent back automatically, so your login works for the duration of the test
  test 'Profile', :login

  # Now that we're logged in, we can view the profile page
  pull '/profile'

  # The show command displays the last @body from the pull in the browser
  show

  # Now @code, @cookies, @headers, @raw, @history, @body is available
  is @code, 200
  is @cookies, :a? => Hash
  is @headers, :a? => Hash
  is @raw, :a? => Hash
  is @history, :a? => Array
  is @body, :a? => String

  # Check if the HTML contains a string
  is @body.include?('string')

  # Flexible, many ways to do it.
  is @body =~ /string/, Integer
  is @body !~ /string/, false
  is @body =~ /string/, :ne => nil

rescue => x
  # You can print more information here if you need to debug
  puts x.message
  puts x.backtrace

  # Err prints a short backtrace and the line number, then stops the tests.
  err x

  # Err takes options as symbols
  err x, :v      # Verbose, prints the full message
  err x, :vv     # Very verbose, prints the full backtrace as well
end
```

Created and maintained by [Fugroup Ltd.](https://www.fugroup.net) We are the creators of [CrowdfundHQ.](https://crowdfundhq.com)

`@authors: Vidar`
