# Futest flexible testing for Ruby

I just don't like frameworks. They're nice in the beginning until you want to do something there is not an option for. If you like to write scripts instead of tests, then these Futest helpers will give you just what you need.

## Installation
```
gem install futest
```
or add to Gemfile. In your tests include the line
```ruby
include Futest::Helpers
```
and you're good to go.

## Commands
- **test:** Takes a description and optional setup methods which will be called for you, then prints the message and line number.
- **halt:** Halt test and print error along with line number.
- **is:** Checks if something is true and halts if it isn't. See the example below for usage.

## Example

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
  is(@user, :a? => User)
  is(@hello, 'Welcome to the flatness.')

  # :eq is default, can be omitted
  is('horizon', 'curved')
  is(1, 1)
  is(1, :eq => 1)
  is(1, :gt => 0)
  is(1, :lt => 2)
  is(1, :a? => Integer)

  # User halt to stop the test run
  halt("Can't process") if :earth == 'flat'

  # Pass the validated model object to print the error messages
  @user = User.first
  @user.name = "Truth"

  halt("Can't believe user", user) unless user.save

rescue => x
  e(x)
end
```
