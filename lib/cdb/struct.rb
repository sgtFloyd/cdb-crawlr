module CDB
  # Modifications to Ruby's Struct class for use within the CDB module.
  # Must be called 'Struct' to play nice with YARD's @attr documentation.
  class Struct < Struct

    # Override Struct's initialize method to accept a hash of members instead.
    def initialize(h={})
      h.each{|k,v| send("#{k}=", v)}
    end

    def as_json(*)
      members.inject({}){|map, m|
        next map unless self[m]
        map[m] = self[m]; map
      }
    end

    def to_json(opts={})
      opts = {space:' ', object_nl:' '}.merge(opts)
      self.as_json.to_json(opts)
    end

  end
end
