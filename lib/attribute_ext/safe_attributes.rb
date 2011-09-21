module AttributeExt
  module SafeAttributes
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def safe_attributes(*attrs)
        @safe_attributes ||= []
        if attrs.empty?
          @safe_attributes
        else
          options = attrs.last.is_a?(Hash) ? attrs.pop : {}
          @safe_attributes << [attrs, options]
        end
      end
    end

    def mass_assignment_authorizer(role = nil)
      if role.nil?
        super + safe_attribute_names(:default)
      else
        super(role) + safe_attribute_names(role)
      end
    end

    def safe_attribute_names(role = :default)
      names = []
      self.class.safe_attributes.collect do |attrs, options|
        if (options[:if].nil? || safe_attrs_call_block(options[:if], role)) &&        # if
            (options[:unless].nil? || !safe_attrs_call_block(options[:unless], role)) # unless
          names += attrs.collect(&:to_s)
        end
      end
      names.uniq
    end
    
    private
    def safe_attrs_call_block(block, role)
      case block.arity
      when 0
        return block.call
      when 1
        return block.call(self)
      else
        return block.call(self, role)
      end
    end
  end
end
