#$stderr = File.open(File::NULL, 'w')

require_relative 'git'
require 'json'

### Note:
# Calculating the merge base for every branch is
# expensive and slow (requires walking the commit
# graph over and over). Since we're going to visit
# all the commits in develop, we can just remove
# branches as we encounter their sha. What's left
# will be independent branches.
###

# Multiple branches may share a head (and therefor sha),
# so we have to store them in buckets.
independent_branches_by_sha = Hash.new { |hash, key| hash[key] = [] }
Git.branch_names.each do |branch_name|
  branch = Branch.new(branch_name, Git.show(branch_name))
  independent_branches_by_sha[branch.commit.sha].push(branch)
end

develop_log = {}
Git.log("origin/develop").each do |commit|
  # Remove branches that have been merged
  independent_branches_by_sha.delete(commit.sha)
  # Hash the develop log
  develop_log[commit.sha] = commit

  data = commit.to_h
  if commit.parents.length == 1
    data[:kind] = 'commit'
  else
    data[:kind] = 'merge-commit'
  end
  puts(data.to_json)
end

independent_branches = independent_branches_by_sha.flat_map { |sha, branches| branches }
independent_branches.each do |branch|
  branch_data = branch.commit.to_h
  branch_data[:kind] = 'independent-branch'
  branch_data[:branch_name] = branch.name
  branch_data[:merge_base] = Git.merge_base(branch.commit.sha, 'origin/develop')
  branch_data[:merge_base_author_date] = develop_log[branch_data[:merge_base]].author_date
  branch_data[:merge_base_committer_date] = develop_log[branch_data[:merge_base]].committer_date
  puts branch_data.to_json
end
