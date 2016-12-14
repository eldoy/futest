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
- **is:** Checks if something is true and halts if it isn't. Options are :eq (eqaulity), :gt (greater than), :lt (less than), :a? (object type)

## Example
This example is taken from https://crowdfundhq.com and demonstrates how it can be used.

```ruby
$test = true
require './config/boot.rb'

###################################
#~~> TEST CACHING - Futest example
###################################

include Futest::Helpers

begin
  # SETUP
  @s = Site.first(:link => 'test1')
  @c = @s.campaigns.first(:active => true)

  halt('No campaigns found') unless @c

  # CAMPAIGN

  test('setup done')

  def create_contribution
    @q = Contribution.new
    @q.site = @s
    @q.campaign = @c
    @q.user = @s.users.first
    @q.amount = 10
    @q.payment_method = 'manual'
    @q.email = 'mail@fugroup.net'
    @q.name = 'fadern'
    @q.fee = @s.fees.first
    @q
  end

  def setup
    @t1, @t2, @t3, @t4 = [ @c.reload.contributions_count,
      @c.reload.contributions_active_count,
      @s.reload.contributions_count,
      @s.reload.contributions_active_live_count]
  end

  # Set variables
  setup
  @q = create_contribution

  halt('should save contribution', @q) unless @q.save

  test('create new contribution')
  is(@c.reload.contributions_count, @t1 + 1)
  is(@c.reload.contributions_active_count, @t2)
  is(@s.reload.contributions_count, @t3 + 1)
  is(@s.reload.contributions_active_live_count, @t4)

  test('contribution update confirmed increase', :setup)
  @q.update_attribute(:confirmed, true)

  is(@c.reload.contributions_count, @t1)
  is(@c.reload.contributions_active_count, @t2 + 1)
  is(@s.reload.contributions_count, @t3)
  is(@s.reload.contributions_active_live_count, @t4)

  test('contribution update confirmed decrease', :setup)
  @q.update_attribute(:confirmed, false)

  is(@c.reload.contributions_count, @t1)
  is(@c.reload.contributions_active_count, @t2 - 1)
  is(@s.reload.contributions_count, @t3)
  is(@s.reload.contributions_active_live_count, @t4)

  test('contribution update live_payment increased', :setup)
  @q.update_attribute(:confirmed, true)
  @q.update_attribute(:live_payment, true)

  is(@c.reload.contributions_count, @t1)
  is(@c.reload.contributions_active_count, @t2 + 1)
  is(@s.reload.contributions_count, @t3)
  is(@s.reload.contributions_active_live_count, @t4 + 1)

  test('contribution update refund decreased', :setup)
  @q.update_attribute(:refunded, true)

  is(@c.reload.contributions_count, @t1)
  is(@c.reload.contributions_active_count, @t2 - 1)
  is(@s.reload.contributions_count, @t3)
  is(@s.reload.contributions_active_live_count, @t4 - 1)

  test('contribution update refund decreased', :setup)
  @q.update_attribute(:refunded, false)

  is(@c.reload.contributions_count, @t1)
  is(@c.reload.contributions_active_count, @t2 + 1)
  is(@s.reload.contributions_count, @t3)
  is(@s.reload.contributions_active_live_count, @t4 + 1)

  test('contribution destroy decreased', :setup)
  @q.destroy

  is(@c.reload.contributions_count, @t1 - 1)
  is(@c.reload.contributions_active_count, @t2 - 1)
  is(@s.reload.contributions_count, @t3 - 1)
  is(@s.reload.contributions_active_live_count, @t4 - 1)

  def create_user(options = {})
    @u = User.new
    @u.site = @s
    @u.name = 'Flat Earth'
    @u.email = options[:email] || 'mail@fugroup.net'
    @u.password = 'testtest'
    @u.password_confirmation = 'testtest'
    @u
  end

  def setup2
    @w1, @w2 = [@s.reload.users_not_deleted_count, @s.reload.campaigns_not_deleted_active_count]
  end

  test('user not deleted count create', :setup2)

  @u = create_user(:email => "e#{Time.now.to_i}@fugroup.net")
  halt('save user', @u) unless @u.save

  is(@s.reload.users_not_deleted_count, @w1 + 1)
  is(@s.reload.campaigns_not_deleted_active_count, @w2)

  test('user not deleted count delete', :setup2)
  @u.update_attribute(:deleted, true)
  is(@s.reload.users_not_deleted_count, @w1 - 1)

  test('user not deleted count revert', :setup2)
  @u.update_attribute(:deleted, false)
  is(@s.reload.users_not_deleted_count, @w1 + 1)

  test('user not deleted count destroy', :setup2)
  @u.destroy
  is(@s.reload.users_not_deleted_count, @w1 - 1)

  def create_campaign
    @c2 = @c.clone
    @c2.link = nil
    @c2
  end

  test('campaigns not deleted active count', :setup2, :create_campaign)
  halt('create campaign', @c2) unless @c2.save

  is(@s.reload.campaigns_not_deleted_active_count, @w2 + 1)

  test('campaigns not deleted active disable count', :setup2)
  @c2.update_attribute(:active, false)

  is(@s.reload.campaigns_not_deleted_active_count, @w2 - 1)

  test('campaigns not deleted active enable count', :setup2)
  @c2.update_attribute(:active, true)

  is(@s.reload.campaigns_not_deleted_active_count, @w2 + 1)

  test('campaigns not deleted deleted count', :setup2)
  @c2.update_attribute(:deleted, true)

  is(@s.reload.campaigns_not_deleted_active_count, @w2 - 1)

  test('campaigns not deleted active enable count', :setup2)
  @c2.update_attribute(:deleted, false)

  is(@s.reload.campaigns_not_deleted_active_count, @w2 + 1)

  test('campaigns not deleted active disable destroy', :setup2)
  @c2.destroy

  is(@s.reload.campaigns_not_deleted_active_count, @w2 - 1)

rescue => x
  e(x)
end
```
