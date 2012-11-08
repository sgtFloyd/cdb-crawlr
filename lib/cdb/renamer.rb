module CDB
  class Renamer
    EXTENSIONS = %w[cbz cbr]
    ISSUE_NUM = '[\d\.\-b]+'
    INPUT_FORMAT = /#(#{ISSUE_NUM})/
    OUTPUT_FORMAT  = "%{series} #%{num} (%{cover_date})"

    def initialize(options)
      @path = options[:path]
      @cdb_id = options[:args]
      @force = options[:force]
      @ignore = options[:ignore]
    end

    def execute
      @rename_map =
        files.each_with_object({}) do |filename, map|
          map[filename]= transform(filename)
        end.select{|k,v| v}

      return unless verify_map
    end

  private

    def verify_map
      dups = @rename_map.select do |k,v|
        @rename_map.values.count(v) > 1
      end
      dups.keys.uniq.each do |k|
        padded = pad(k, dups.keys.map(&:length).max)
        puts "ERROR: output name clash: #{padded} => #{dups[k]}"
      end
      dups.empty?
    end

    def transform(filename)
      return unless num = parse_issue_num(filename)
      if issue = issues[num]
        new_name = generate_output(filename, issue)
        puts "#{pad(filename)} => #{new_name}"
        new_name
      else
        puts "WARNING: #{filename}: unknown issue: #{num}" unless @ignore
      end
    end

    def parse_issue_num(filename)
      if match = filename.match(INPUT_FORMAT)
        num = match[1].gsub(/^0+|\.$/,'')
        num = '0' if num == ''
        num
      else
        puts "WARNING: #{filename}: invalid input format" unless @ignore
      end
    end

    def generate_output(filename, issue)
      json = issue.as_json
      json[:series] = issue.series.name
      output = OUTPUT_FORMAT % json
      sanitize(output + File.extname(filename))
    end

    def sanitize(filename)
      filename.gsub(/\:/, ' -')
        .gsub(/\/\\\<\>/, '-')
        .gsub(/\?\*\|\"/, '_')
    end

    def pad(file, max=nil)
      max ||= files.map(&:length).max
      file + (' '*(max-file.length))
    end

    def files
      Dir.chdir(@path) do
        @files ||= EXTENSIONS
          .map{|e| Dir["*.#{e}"]}.flatten
          .select{|f| File.file?(f)}.sort
      end
      @files
    end

    def series
      @series ||= CDB::Series.show(@cdb_id)
    end

    def issues
      # Only act on issues - not TPB, HC, or anything else
      @issues ||= Hash[series.issues
        .select{|i| i.num.match(/^#{ISSUE_NUM}$/)}
        .map{|i| [i.num.to_s, i]}]
    end

  end
end
