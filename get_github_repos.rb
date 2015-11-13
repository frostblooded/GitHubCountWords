require 'octokit'
require 'fileutils'
require_relative 'src/result.rb'
require_relative 'src/word_counter.rb'

client = Octokit::Client.new \
  access_token: ''

starting_id = (rand * 1_000_000).round
last_id = starting_id
puts "Starting download with repo #{starting_id}"

loop do
  FileUtils.rm_rf(Dir.glob('data/*'))
  repos = client.all_repositories(since: last_id)
  repos_to_download = 10

  repos[0..repos_to_download - 1].each_with_index do |repo, index|
    print "\rDownloading repo #{index + 1} of #{repos_to_download}"
    `git clone #{repo.html_url} data/#{repo.name} --depth 1 --single-branch --quiet`
  end

  last_id += repos_to_download
  puts # new line
  puts 'Download complete! Counting words...'
  files = Dir['data/**/*'].select { |f| File.file? f }
  res = Result.new
  current_file = 1

  files.each do |file|
    print "\rProcessing file #{current_file} of #{files.size} (#{((current_file.to_f / files.size) * 100).round(2)}%)" if current_file % 100 == 0
    word_counter = WordCounter.new
    tmp_res = word_counter.parse_file file
    res.word_counts.merge!(tmp_res.word_counts.to_h) { |_, oldval, newval| newval + oldval }
    res.marks_count += tmp_res.marks_count
    current_file += 1
  end

  res_file = '{}'
  if File.exist? 'results.json'
    res_file = File.read('results.json')
    res_file = JSON.parse(res_file)
    res.word_counts.merge!(res_file['words'].to_h) { |_, oldval, newval| newval + oldval }
    res.marks_count += res_file['marks']
  end

  res.word_counts = res.word_counts.sort_by { |word, count| [-count, word] }

  File.open('results.json', 'w') do |result_file|
    result_file << res.to_json
  end

  puts # new line
end
