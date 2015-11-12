require 'octokit'
require './src/result.rb'
require './src/word_counter.rb'

client = Octokit::Client.new \
  access_token: ''

last_id = 999 # for debugging purposes
while last_id < 1000
  repos = client.all_repositories(since: last_id)
  last_id = repos.last.id

  repos.each_with_index do |repo, index|
    print "\rDownloading repo #{index + 1} of #{repos.size}"
    `git clone #{repo.html_url} data/#{repo.name} --depth 1 --single-branch`
  end

  puts 'Download complete! Counting words!'

  res = Result.new
  checked_file = 1.0
  files = Dir['data/**/*'].select { |f| File.file? f }
  files.each do |file|
    print "\r#{checked_file.round(0)} of #{files.count} files counted! (#{((checked_file / files.count) * 100).round(2)}%)" if checked_file % 50 == 0

    word_counter = WordCounter.new
    tmp_res = word_counter.parse_file file
    res.word_counts.merge!(tmp_res.word_counts.to_h) { |_, oldval, newval| newval + oldval }
    res.marks_count += tmp_res.marks_count
    checked_file += 1
  end

  res.word_counts = res.word_counts.sort_by { |word, count| [-count, word] }

  File.open('results.json', 'w') do |result_file|
    result_file << res.to_json
  end

  puts 'Done!'
end
