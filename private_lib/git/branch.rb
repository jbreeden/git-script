class Branch
  attr_accessor :name, :commit

  def initialize(name, commit)
    @name = name
    @commit = commit
  end
end
