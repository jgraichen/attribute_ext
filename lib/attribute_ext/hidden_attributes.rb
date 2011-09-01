module AttributeExt
  module HiddenAttributes
    def self.included(base)
      base.extend(ClassMethods)
      base.alias_method_chain :to_xml, :hidden_attrs
      base.alias_method_chain :as_json, :hidden_attrs
      base.alias_method_chain :serializable_hash, :hidden_attrs
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
      options ||= {}
      options[:except] = [] unless options[:except].is_a?(Array)
      options[:except] += hidden_attribute_names(:xml, options)
      
      to_xml_without_hidden_attrs(options)
    end
  
    def as_json_with_hidden_attrs(options = nil, &block)
      options ||= {}
      options[:except] = [] unless options[:except].is_a?(Array)
      options[:except] += hidden_attribute_names(:json, options)
      options[:hidden_attributes_json_export] = true
            
      as_json_without_hidden_attrs(options)
    end
  
    def serializable_hash_with_hidden_attrs(options = nil)
      options ||= {}
      options[:except] = [] unless options[:except].is_a?(Array)
      if options[:hidden_attributes_json_export] == true
        options[:except] += hidden_attribute_names(:json, options)
      else
        options[:except] += hidden_attribute_names(:hash, options)
      end
      
      serializable_hash_without_hidden_attrs(options)
    end
  
    private
    
    def hidden_attribute_names(format, options)
      names = []
  
      self.class.hide_attributes.collect do |attrs, aopts|
        if (aopts[:if].nil? || aopts[:if].call(self, format, options)) &&    # if
        (aopts[:unless].nil? || !aopts[:unless].call(self, format, options)) # unless
          names += attrs.collect(&:to_s)
        end
      end
      names.uniq
    end
  end
end
