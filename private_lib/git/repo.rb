# Just dispatches git commands in the working
# directory of the repo
class Repo
  attr_accessor :path

  def initialize(directory)
    @path = directory
  end

  def cd(&block)
    do_cd = (File.expand_path(Dir.pwd) != File.expand_path(@path))
    if do_cd
      pwd = Dir.pwd
      $stderr.puts "cd to #{@path}"
      Dir.chdir(@path)
    end
    yield
  ensure
    if do_cd
      $stderr.puts "cd back to #{pwd}"
      Dir.chdir(pwd)
    end
  end
  alias chdir cd

  def method_missing(name, *args, &block)
    if Git.respond_to? name
      self.cd do
        Git.send(name, *args, &block)
      end
    else
      raise StandardError.new("Method #{name} is undefined for class Repo")
    end
  end
end
