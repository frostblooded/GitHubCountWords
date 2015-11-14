require_relative 'src/github_cloner.rb'
require_relative 'src/file_processor.rb'
require_relative 'src/file_writer.rb'


loop do
  GitHubCloner.download_repos 'data', 1
  puts
  data = FileProcessor.process_files 'data'
  puts
  FileWriter.write_to_file 'results.json', data
end
