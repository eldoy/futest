test 'Features'

test '* stop'

# Uncomment to run, will stop the test
# m = Model.new
# m.errors[:hello] = ['test']
# stop('model', m)

test '* err'

# Uncomment to run, will stop the test
# begin
#   Model.new.not
# rescue => x
#   err x
#   err x, :v
#   err x, :vv
# end

test '* is'

s = 'hello'
is true
is s, 'hello'
is s == 'hello', true
is s != 'hello', false
is s.start_with?('h'), true
is nil, NilClass
is nil, nil
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

test '* pull'

@host = 'http://fugroup.net'
# Quickly change host:
# @host = 'http://waveorb.com'

pull

# Will open the last @body in the browser
# show

is @host, 'http://fugroup.net'
is @page, :a? => String
is @code, 200
is @cookies, :a? => Hash
is @headers, :a? => Hash
is @raw, :a? => Hash
is @history, :a? => Array
is @body, :a? => String

is @body =~ /body/, Integer
is @body !~ /body/, false
is @body =~ /body/, :ne => nil
is @body.include?('body'), true

pull '/nisse'
is @code, 404
