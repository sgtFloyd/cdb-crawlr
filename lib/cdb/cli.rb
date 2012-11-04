require 'pp'

module CDB
  class CLI
    COMMANDS = %w[search show]
    TYPES = %w[series issue issues]

    def initialize(options={})
      @options = options
    end

    def [](k)
      @options[k]
    end

    def []=(k, v)
      v = v.to_s.strip
      case k
      when :command
        v = v.downcase
        raise unless COMMANDS.include?(v)
      when :type
        v = v.downcase
        if self[:command] == 'show'
          # remove when "show issue" is supported
          raise unless v == 'series'
        else
          raise unless TYPES.include?(v)
        end
      when :args
        raise "invalid args" if v.empty?
      end
      @options[k] = v
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

  end
end
