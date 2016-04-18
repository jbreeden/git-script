require 'pathname'

class Node
  attr_accessor :sha, :name, :parent, :children
  
  def initialize(name, sha, parent = nil)
    self.name = name
    self.sha = sha
    self.parent = parent
    self.children = []
  end
  
  def path
    if self.parent && !self.parent.root?
      File.join(self.parent.path, self.name)
    else
      self.name
    end
  end
  
  def walk(&block)
    block[self]
    self.walk_children(&block)
  end
  
  def walk_children(&block)
    self.children.each { |c| c.walk(&block) }
  end
  
  def root?
    false
  end
  
  # Parses a node from `git ls-tree`
  def self.tokenize(line)
    line.match(/(?<mode>\S+) (?<type>\S+) (?<sha>\S+)\t(?<path>.*)/)
  end
  
  def [](path)
    path.split(File::SEPARATOR).inject(self) do |parent, part|
      if parent
        parent.children.find { |c| c.name == part }
      else
        nil
      end
    end
  end
end

class Blob < Node
  def type
    'blob'
  end
end

class Tree < Node
  def type
    'tree'
  end
  
  class Root < Tree
    def path
      Git.root
    end
    
    def root?
      true
    end
  end
  
  def self.head
    @head ||= self.from_ref('HEAD')
  end
  
  def self.from_ref(ref, path=nil)
    unless ['commit', 'tree'].include?(Git.object_type(ref))
      raise "Expected a reference to a commit or tree"
    end
    
    tree = Root.new(ref, Git.rev_parse(ref))
    files = nil

    make_tree = proc {
      `git ls-tree -r -t #{ref}`.split("\n").map { |line|
        line.strip
      }.select { |line|
        line && line.length > 0
      }.map { |line|
        Node.tokenize(line)
      }.each { |tokens|
        parent_names = tokens['path'].split(File::SEPARATOR).select { |p| 
          !p.nil? && p.length > 0
        }
        if tokens['path'].start_with?(File::SEPARATOR)
          parent_names.unshift(File::SEPARATOR)
        end

        name = parent_names.pop
        
        next if name == '.' || name == '..'

        new_node = tokens['type'] == 'blob' ?
          Blob.new(name, tokens['sha']) :
          Tree.new(name, tokens['sha'])

        new_node.parent = parent_names.length > 0 ?
          parent_names.inject(tree) { |tree, parent| tree[parent] } :
          tree

        new_node.parent.children.push(new_node)
      }
    }
    
    if path
      Dir.chdir(path, &make_tree)
    else
      make_tree[]
    end
    
    tree
  end
end
