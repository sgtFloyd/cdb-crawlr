require 'pp'

module CDB
  class CLI
    COMMANDS = %w[search show rename]
    TYPES = %w[series issue issues]

    def initialize(options={})
      @options = options
    end

    def [](k)
      @options[k]
    end

    def []=(k, v)
      v = v.to_s.strip
      begin
        send("#{k}=", v)
      rescue NoMethodError
        @options[k] = v
      end
    end

    def execute
      send self[:command]
    end

  private

    def search
      case self[:type]
      when 'series'
        CDB::Series.search(self[:args]).each{|r| puts r.to_json}
      when 'issue', 'issues'
        CDB::Issue.search(self[:args]).each{|r| puts r.to_json}
      end
    end

    def show
      case self[:type]
      when 'series'
        res = CDB::Series.show(self[:args])
        res.issues.each{|i| i.series=nil}
        puts res.to_json(array_nl:"\n", object_nl:"\n", indent:'  ')
      end
    end

    def rename
      renamer = CDB::Renamer.new(@options)
      renamer.execute
    end

    def args=(v)
      raise "invalid args" if v.empty?
      @options[:args] = v
    end

    def command=(v)
      v = v.downcase
      raise unless COMMANDS.include?(v)
      @options[:command] = v
    end

    def type=(v)
      v = v.downcase
      error = "invalid TYPE: #{v}" unless v.empty?
      if @options[:command] == 'show'
        # remove when "show issue" is supported
        raise error.to_s unless v == 'series'
      else
        raise error.to_s unless TYPES.include?(v)
      end
      @options[:type] = v
    end

    def path=(v)
      error = "#{v}: No such directory" unless v.empty?
      raise error.to_s unless File.directory?(v)
      @options[:path] = v
    end

  end
end
