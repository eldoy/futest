# Futest flexible testing for Ruby

I just don't like frameworks. They're nice in the beginning until you want to do something there is not an option for. If you like to write scripts instead of tests, then these Futest helpers will give you just what you need.

### Installation
```
gem install futest
```
or add to Gemfile. In your tests include the line
```ruby
include Futest::Helpers
```
and you're good to go.

### Commands
- **test:** Takes a description and optional setup methods which will be called for you, then prints the message and line number.
- **stop:** Stop test and print error along with line number.
- **is:** Checks if something is true and stops if it isn't. See the usage section below.
- **pull:** Pulls a URL and expose varibles with info you can use
- **show:** Shows the body from the last pull in your web browser

### Usage

```ruby
require 'futest'

include Futest::Helpers

# Use begin to have formatted output on error
begin

  # Print string in green
  test('Testing Heliocentric Model')

  # Optionally pass setup methods to run as symbols
  # define setup methods
  def setup; @hello = 'Welcome to the curve.'; end

  def setup_user
    @user = User.first
  end

  test('Reality', :setup, :setup_user)
  is @user, :a? => User
  is @hello, 'Welcome to the flatness.'

  # :eq is default, can be omitted
  is 'horizon', 'curved'
  is 1, 1
  is 1, :eq => 1
  is 1, :gt => 0
  is 1, :lt => 2
  is 1, :a? => Integer

  # Use stop to end the test run
  stop("Can't process") if :earth == 'flat'

  # Pass the validated model object to print the error messages
  @user = User.first
  @user.name = "Truth"

  stop("Can't believe user", user) unless user.save

  # Here are the tests that show how it works
  # There options are:
  # :a?, :a, :eq, :lt, :lte, :gt, :gte, :in, :nin, :has
  s = 'hello'
  is s, 'hello'
  is s == 'hello', true
  is s != 'hello', false
  is s.start_with?('h'), true
  is nil, NilClass

  is 1, 1
  is 1, Integer
  is 1, :a? => Integer
  is 1, :a => Integer
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

  # Check if the HTML contains a string
  is @body.include?('body'), true

  # Flexible, many ways to do it.
  is @body =~ /body/, Integer
  is @body !~ /body/, false
  is @body =~ /body/, :ne => nil

rescue => x
  # You can print more information here if you need to debug
  puts x.message
  err(x)
end
```

Created and maintained by [Fugroup Ltd.](https://www.fugroup.net) We are the creators of [CrowdfundHQ.](https://crowdfundhq.com)

`@authors: Vidar`
