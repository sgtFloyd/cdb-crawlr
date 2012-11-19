module CDB
  class Renamer
    EXTENSIONS = %w[cbz cbr]
    ISSUE_NUM = '[\d\.]+[a-z]?'
    INPUT_FORMAT = /#(#{ISSUE_NUM})/
    OUTPUT_FORMAT  = "%{series} #%{padded_num} %{name} (%{cover_date})"

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

      do_rename if verify_map
    end

  private

    def do_rename
      Dir.chdir(@path) do
        @rename_map.each do |source, destination|
          next if source == destination
          puts "#{pad(source)} => #{destination}"
          if @force
            %x[ mv "#{source}" "#{destination}" ]
          end
        end
      end
    end

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
        generate_output(filename, issue)
      else
        puts "WARNING: #{filename}: unknown issue: #{num}"
      end
    end

    def parse_issue_num(filename)
      base = filename.chomp(File.extname(filename))
      if match = base.match(INPUT_FORMAT)
        num = match[1].gsub(/^0+|\.$/,'')
        num = '0' if num.empty?
        num
      else
        puts "WARNING: #{filename}: invalid input format" unless @ignore
      end
    end

    def generate_output(filename, issue)
      json = issue.as_json
      json[:series] = issue.series.name
      json[:padded_num] = pad_num(issue.num)
      json[:name] = "- #{json[:name]}" if !json[:name].empty?
      output = OUTPUT_FORMAT % json
      sanitize(output + File.extname(filename))
    end

    def sanitize(filename)
      filename.gsub(/[:]/, ' -')
        .gsub(/[\/\\<>]/, '-')
        .gsub(/[\?\*|"]/, '_')
        .gsub(/\s+/, ' ')
    end

    def pad(file, max=nil)
      max ||= files.map(&:length).max
      file + (' '*(max-file.length))
    end

    def pad_num(num, max=nil)
      max ||= max_num_length
      '0'*(max-num.to_s.length)+num.to_s
    end

    def files
      Dir.chdir(@path) do
        @files ||= EXTENSIONS
          .map{|e| Dir["*.#{e}"]}.flatten
          .select{|f| File.file?(f)}.sort
      end
      @files
    end

    def max_num_length
      @max_num ||= files.map{|f| parse_issue_num(f).to_s.length}.max
    end

    def series
      @series ||= CDB::Series.show(@cdb_id)
    end

    def issues
      # Only act on issues - not TPB, HC, or anything else
      @issues ||= Hash[series.issues
        .select{|i| i.num.match(/^#{ISSUE_NUM}$/i)}
        .map{|i| [i.num.to_s, i]}]
    end

  end
end
