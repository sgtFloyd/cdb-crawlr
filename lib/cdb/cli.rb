require 'pp'

module CDB
  class CLI
    COMMANDS = %w[search]
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
        v = v.downcase.gsub(/^=/, '')
        raise unless TYPES.include?(v)
      when :args
        if self[:command] == 'search'
          raise "invalid search query" if v.empty?
        end
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

  end
end
