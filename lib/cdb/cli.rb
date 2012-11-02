require 'pp'

module CDB
  class CLI
    COMMANDS = %w[search]
    SCOPES = %w[all title issue]

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
      when :scope
        v = v.downcase.gsub(/^=|s$/, '')
        raise unless SCOPES.include?(v)
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
      case self[:scope] || 'all'
      when 'all'
        CDB.search(self[:args]).each do |key, res|
          puts key.to_s.capitalize+':'
          res.each{|r| puts '  '+r.to_json}
        end
      when 'title'
        CDB::Title.search(self[:args]).each{|r| puts r.to_json}
      when 'issue'
        CDB::Issue.search(self[:args]).each{|r| puts r.to_json}
      end
    end

  end
end
