
module ActiveRecord
  class Base
    def as_json(options)
      if options[:include]
        serializable_hash(options)
      else
        options
      end
    end
    
    def to_xml(options)
      options
    end
    
    def serializable_hash(options)
      options
    end
    
    def mass_assignment_authorizer
      [:always_there]
    end
    
    def self.alias_method_chain(target, feature)
      alias_method "#{target}_without_#{feature}", target
      alias_method target, "#{target}_with_#{feature}"
    end
  end
end