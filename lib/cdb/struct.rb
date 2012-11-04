module CDB
  # Modifications to Ruby's Struct class for use within the CDB module.
  # Must be called 'Struct' to play nice with YARD's @attr documentation.
  class Struct < Struct

    # Override Struct's initialize method to accept a hash of members instead.
    def initialize(h={})
      h.each{|k,v| send("#{k}=", v)}
    end

    def as_json(*)
      members.each_with_object({}){|m, map|
        next map unless self[m]
        case self[m]
        when Array
          map[m] = self[m].collect(&:as_json)
        else
          map[m] = self[m]
        end
      }
    end

    def to_json(opts={}, depth=0)
      opts = opts.to_h rescue opts
      opts = {space:' ', object_nl:' '}.merge(opts)
      self.as_json.to_json(opts)
    end

  end
end
