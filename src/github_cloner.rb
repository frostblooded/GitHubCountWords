require 'octokit'
require 'fileutils'

class GitHubCloner
  ALL_GITHUB_REPOS = 1_000_000

  def self.download_repos(dir, count)
    client = Octokit::Client.new \
      access_token: '5981e505bd2008c278e01e1acd9701f79e395d6f'

    starting_id = (rand * ALL_GITHUB_REPOS).round
    puts "Starting download with repo #{starting_id}"

    FileUtils.rm_rf(Dir.glob("#{dir}/*"))
    repos = client.all_repositories(since: starting_id)

    repos[0..count - 1].each_with_index do |repo, index|
      print "\rDownloading repo #{index + 1} of #{count}"
      `git clone #{repo.html_url} #{dir}/#{repo.name} --depth 1 --single-branch --quiet`
    end
  end
end