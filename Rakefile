task :clean do
  Dir['*.gem'].each { |f| rm f }
end

task :build => :clean do
  sh 'gem build ./git-scripts.gemspec'
end

task :install => :build do
  sh "gem install #{Dir['*.gem'][0]}"
end

task :uninstall do
  sh "gem uninstall git-scripts"
end
