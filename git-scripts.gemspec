Gem::Specification.new do |s|
  s.name = 'git-scripts'
  s.authors = ['Jared Breeden']
  s.version = '0.1.0'
  s.summary = 'A collection of useful Ruby scripts'
  # "private" lib folder so it doesn't pollute the gem space
  # (These things are not to be exported)
  s.files = Dir['private_lib/**/*.rb']
  s.bindir = 'bin'
  s.executables = Dir['./bin/*'].map { |f| File.basename f }
end
