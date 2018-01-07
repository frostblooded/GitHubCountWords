require_relative 'src/github_cloner.rb'
require_relative 'src/file_processor.rb'
require_relative 'src/file_writer.rb'

DATA_DIR = 'data'
REPOS_AT_A_TIME = 1
RESULTS_FILE = 'results.json'

loop do
  GitHubCloner.download_repos DATA_DIR, REPOS_AT_A_TIME
  puts
  data = FileProcessor.process_files DATA_DIR
  puts
  FileWriter.write_to_file RESULTS_FILE, data
end
