Gem::Specification.new do |s|

  s.name        = 'producer-consumers'
  s.version     = '0.0.1'
  s.date        = '2013-06-24'
  s.summary     = ''
  s.description = ''
  s.authors     = ['Chris Rogers']
  s.email       = ''
  s.files       = Dir["#{File.dirname __FILE__}/**/*.rb"]
  s.homepage    = 'https://github.com/rcrogers/producer-consumers'

  [
    #'linguistics',
  ].each{|x| s.add_dependency x}

end
