module CDB
  class Renamer
    EXTENSIONS = %w[cbz cbr]
    ISSUE_NUM = '[\d\.\-]+'
    INPUT_FORMAT = /#(#{ISSUE_NUM})/
    OUTPUT_FORMAT  = "%{series} #%{num} (%{cover_date})"

    def initialize(options)
      @path = options[:path]
      @cdb_id = options[:args]
      @force = options[:force]
      @ignore = options[:ignore]
    end

    def execute
      files.map do |filename|
        if num = parse_issue_num(filename)
          if issue = issues[num]
            new_name = generate_output(filename, issue)
            puts "#{pad(filename)} => #{new_name}"
          else
            puts "#{filename}: unknown issue #{num}" unless @ignore
          end
        else
          puts "#{filename}: invalid format" unless @ignore
        end
      end
    end

  private

    def parse_issue_num(filename)
      if filename.match(INPUT_FORMAT)
        match[1].gsub(/^0+/,'').to_f
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

    def pad(file)
      max = files.map(&:length).max
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
      # Only act on "Issue" issues - not TPB, HC, or anything else
      @issues ||= Hash[series.issues
        .select{|i| i.num.match(/^#{ISSUE_NUM}$/)}
        .map{|i| [i.num.to_f, i]}]
    end

  end
end
