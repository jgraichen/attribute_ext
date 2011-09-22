module AttributeExt
  module SafeAttributes
    def self.included(base)
      base.extend(ClassMethods)
      base.alias_method_chain :mass_assignment_authorizer, :safe_attrs
    end

    module ClassMethods
      def safe_attributes(*attrs)
        @safe_attributes ||= []
        if attrs.empty?
          @safe_attributes
        else
          options = attrs.last.is_a?(Hash) ? attrs.pop : {}
          @safe_attributes << [attrs, safe_attributes_opts(options)]
        end
      end
      
      private
      def safe_attributes_opts(options)
        opts = { :as => [] }
        opts[:as]    += options[:as].is_a?(Array) ? options[:as] : [options[:as]] if options[:as]
        opts[:if]     = options[:if] if options[:if].is_a?(Proc)
        opts[:unless] = options[:unless] if options[:unless].is_a?(Proc)
        opts
      end
    end

    def mass_assignment_authorizer_with_safe_attrs(role = nil)
      attrs = role.nil? ? mass_assignment_authorizer_without_safe_attrs : mass_assignment_authorizer_without_safe_attrs(role)
      attrs += safe_attribute_names(role ? role : :default)
      attrs.uniq
    end

    def safe_attribute_names(role = :default)
      names = []
      self.class.safe_attributes.collect do |attrs, options|
        next unless options[:as].empty? or options[:as].include?(role)
        next unless options[:if].nil? or safe_attrs_call_block(options[:if], role)
        next unless options[:unless].nil? or !safe_attrs_call_block(options[:unless], role)

        names += attrs.collect(&:to_s)
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
