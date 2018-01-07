class FileWriter
  def self.write_to_file(file, data)
    res_file_data = '{}'
    if File.exist? file
      res_file_data = File.read(file)
      res_file_data = JSON.parse(res_file_data)
      data.word_counts.merge!(res_file_data['words'].to_h) { |_, oldval, newval| newval + oldval }
      data.marks_count += res_file_data['marks']
    end

    data.word_counts = data.word_counts.sort_by { |word, count| [-count, word] }

    File.open(file, 'w') do |result_file|
      result_file << data.to_json
    end
  end
end