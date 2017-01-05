Gem::Specification.new do |s|
  s.name        = 'futest'
  s.version     = '0.1.1'
  s.date        = '2017-01-05'
  s.summary     = "Futest flexible testing for Ruby"
  s.description = "Program your tests as normal scripts without dependencies, mocks, stubs and rules."
  s.authors     = ["Fugroup Limited"]

  s.add_runtime_dependency 'rest-client', '>= 2.0'

  s.email       = 'mail@fugroup.net'
  s.homepage    = 'https://github.com/fugroup/futest'
  s.license     = 'MIT'

  s.require_paths = ['lib']
  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
end
