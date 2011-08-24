module AttributeExt
  module HiddenAttributes
    def self.included(base)
      base.extend(ClassMethods)
      base.alias_method_chain :to_xml, :hidden_attrs
      base.alias_method_chain :to_json, :hidden_attrs
    end
  
    module ClassMethods
      def hide_attributes(*attrs)
        @hidden_attributes ||= []
        if attrs.empty?
          @hidden_attributes
        else
          options = attrs.last.is_a?(Hash) ? attrs.pop : {}
          @hidden_attributes << [attrs, options]
        end
      end
    end
  
    def to_xml_with_hidden_attrs(options = nil, &block)
      call_with_sanitized_attrs(:xml, options, &block)
    end
  
    def to_json_with_hidden_attrs(options = nil)
      call_with_sanitized_attrs(:json, options)
    end
  
    private
  
    def call_with_sanitized_attrs(format, options = nil, &block)
      options ||= {}
      names = []
  
      self.class.hide_attributes.collect do |attrs, aopts|
        if (aopts[:if].nil? || aopts[:if].call(self, format, options)) &&    # if
        (aopts[:unless].nil? || !aopts[:unless].call(self, format, options)) # unless
          names += attrs.collect(&:to_s)
        end
      end
      names.uniq
  
      send("to_#{format}_without_hidden_attrs".to_sym, {:except => names}.merge(options), &block)
    end
  end
end
