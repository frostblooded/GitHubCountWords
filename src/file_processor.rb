require_relative './result.rb'
require_relative './word_counter.rb'

class FileProcessor
  def self.process_files(dir)
    word_counter = WordCounter.new
    files = Dir[dir + '/**/*'].select { |f| File.file? f }
    res = Result.new
    current_file = 1

    files.each do |file|
      print "\rProcessing file #{current_file} of #{files.size} (#{((current_file.to_f / files.size) * 100).round(2)}%)" if current_file % 10 == 0
      tmp_res = word_counter.parse_file file
      res.word_counts.merge!(tmp_res.word_counts.to_h) { |_, oldval, newval| newval + oldval }
      res.marks_count += tmp_res.marks_count
      current_file += 1
    end

    res
  end
end