require './lib/futest'

include Futest::Helpers

# Use begin to have formatted output
begin

  test('Hello')
  is('hello', 'hello')
  is(1, 1)
  is(1, :eq => 1)
  is(1, :lt => 2)
  is(1, :a? => Integer)


rescue => x
  e(x)
end
