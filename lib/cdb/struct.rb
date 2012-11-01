module CDB

  # Prodives modifications to Ruby's Struct class for use within the CDB module.
  # Must be called 'Struct' to play nice with YARD's @attr documentation.
  class Struct < Struct

    # Override Struct's initialize method to accept a hash of members instead.
    def initialize(h={})
      h.each{|k,v| send("#{k}=", v)}
    end

    def to_json(*a)
      members.inject({}){|map, m|
        map[m] = self[m]; map
      }.to_json(*a)
    end

  end
end
