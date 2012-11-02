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
      case k
      when :command
        v = v.to_s.strip.downcase
        raise unless COMMANDS.include?(v)
      when :scope
        v = v.to_s.strip.downcase.gsub(/^=|s$/, '')
        raise unless SCOPES.include?(v)
      when :args
        v = v.to_s.strip
        if self[:command] == 'search'
          raise "invalid search query" if v.empty?
        end
      end
      @options[k] = v
    end

    def execute
      puts @options
    end

  end
end
