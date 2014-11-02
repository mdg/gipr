require 'net/https'
require 'uri'

module Gipr
	extend self

	GITHUB_HOST = URI("https://api.github.com")

	def clean_index?()
		sh('git diff-index --quiet --cached HEAD')
		$?.exitstatus === 0
	end

	def create_pr(base, target_branch, patch)
		full_base = sh("git rev-parse --symbolic-full-name #{base}").strip
		m = /^refs\/remotes\/([^\/]+)\/.*$/.match(full_base)
		if m.nil?
			exit(1)
		end
		base_remote = m[1]

		commit_hash = create_commit(base, patch)
		puts commit_hash

		push_cmd = "git push #{base_remote} #{commit_hash}:refs/heads/#{target_branch}"
		puts push_cmd
		sh(push_cmd)

		#post(github_repo_name, base_repo, target_branch)
	end

	def create_commit(base, patch)
		current_branch = sh('git rev-parse --abbrev-ref HEAD')
		root = sh('git rev-parse --show-toplevel')
		sh("git reset #{base} #{root}")
		sh('git apply --cached', patch)
		exit($?.exitstatus) if $?.exitstatus != 0
		tree = sh('git write-tree').strip
		#puts "tree: #{tree}"
		hash = sh("git commit-tree #{tree} -p #{base} -m test_commit")
		hash.strip!
		sh("git reset HEAD #{root}")
		return hash
	end

	def git_config(key)
		sh('git config --get #{key}')
	end

	def post(repo, base_branch, target_branch)
		#Net::HTTP::Get.new(
	end

	def sh(cmd, input=nil)
		if input == nil
			return `#{cmd}`
		else
			output = nil
			process = IO.popen(cmd, 'w+') do |pipe|
				pipe.write(input)
				pipe.close_write()
				output = pipe.read()
			end
			return output
		end
	end
end
