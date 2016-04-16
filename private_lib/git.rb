require 'pp'
require 'english'
require 'fileutils'
require 'shellwords'
require_relative './git/branch'
require_relative './git/commit'
require_relative './git/repo'
require_relative './git/tree'

module Git
  # All methods are "instance" methods to allow inclusion/extension
  # into other modules & classes. Extends itself to allow methods
  # to be called directly as module methods.
  extend self

  def git(argv, verbose=false)
    out = nil
    $stdout.puts "git #{argv}" if verbose
    out = IO.popen("git #{argv}", 'r')
    result = out.read
    Process.wait(out.pid)
    if $CHILD_STATUS.exitstatus != 0
      raise "git failed with exit status #{$CHILD_STATUS.exitstatus}"
    end
    result.strip
  ensure
    out.close if out
  end
  
  def root
    @root ||= rev_parse('--show-toplevel')
  end
  
  def rev_parse(rev)
    git("rev-parse #{rev}")
  end

  def user_email
    git("config user.email").strip
  end

  def user_name
    git("config user.name").strip
  end

  def current_branch
    git('status')[/On branch ([^\n]+)\n/m, 1]
  end

  def branch_names
    git('branch -a').each_line.map { |l| l.gsub(/(^\s*\*\s*)|(\s*->.*$)/, '').strip }
  end

  def remote_uri(remote_name)
    git("remote -v")[/#{remote_name}\s+([^\n\s]+)/m, 1]
  end

  def merge_base(ref1, ref2)
    git("merge-base #{ref1} #{ref2}").strip
  end

  def log(include=[], exclude=[])
    result = []
    IO.popen("git log --stdin --date=iso --pretty=format:\"%H,%T,%P,%an,%ae,%ad,%cn,%ce,%cd,%s\"", 'r+') do |io|
      include.each do |inc|
        io.puts inc
      end
      exclude.each do |exc|
        io.puts "^#{exc}"
      end
      io.close_write
      while l = io.gets
        result.push Commit.parse(l)
      end
    end
    result
  end

  def show(commitish)
    Commit.pars(git("log --stdin --date=iso --pretty=format:\"%H,%T,%P,%an,%ae,%ad,%cn,%ce,%cd,%s\" #{commitish} --max-count=1")[0])
  end

  def diff(from_hash, to_hash=nil)
    if to_hash
      text = git("diff --numstat #{from_hash} #{to_hash}")
    else
      text = git("diff --numstat #{from_hash}")
    end

    text.split("\n")
      .map { |line|
        parts = line.split("\t")
      }.reject { |parts|
        # Binary files will have a '-' for the additions and deletions,
        # so we can use that to ignore them
        parts[0] == '-' && parts[1] == '-'
      }.map { |parts|
        { additions: parts[0].to_i, deletions: parts[1].to_i, file: parts[2] }
      }
  end

  def show_ref(pattern=nil)
    refs = []
    regex = pattern ? Regexp.new(pattern) : nil
    `git show-ref`.each_line do |l|
      tokens = l.strip.split(/\s+/)
      refs.push({ sha: tokens[0], name: tokens[1] }) unless regex && !(l =~ regex)
    end
    refs
  end

  def ref_names(pattern=nil)
    show_ref(pattern).map { |ref| ref[:name] }
  end
end
