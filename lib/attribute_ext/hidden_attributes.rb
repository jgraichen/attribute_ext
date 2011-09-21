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
          @hidden_attributes << [attrs, hide_attributes_opts(options)]
        end
      end
      
      private
      def hide_attributes_opts(options)
        opts = {}
        opts[:except] = [:hash] unless options[:on_hash]
        opts[:except] = options[:except].to_a unless options[:except].nil?
        opts[:only]   = options[:only].to_a
        opts[:if]     = options[:if] if options[:if].is_a?(Proc)
        opts[:unless] = options[:unless] if options[:unless].is_a?(Proc)
        opts
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
      if options[:hidden_attributes_json_export]
        options[:except] += hidden_attribute_names(:json, options)
      else
        options[:except] += hidden_attribute_names(:hash, options)
      end
      
      serializable_hash_without_hidden_attrs(options)
    end
    
    def hidden_attribute_names(format, options = {})
      names = []
  
      self.class.hide_attributes.collect do |attrs, opts|
        next unless opts[:only].empty? or opts[:only].include?(format)
        next unless opts[:except].empty? or !opts[:except].include?(format)
        next unless opts[:if].nil? or hidden_attr_call_block(opts[:if], format, options)
        next unless opts[:unless].nil? or !hidden_attr_call_block(opts[:unless], format, options)
        
        names += attrs.collect(&:to_s)
      end
      names.uniq
    end
  
    private
    def hidden_attr_call_block(block, format, opts)
      case block.arity
      when 0
        return block.call
      when 1
        return block.call(self)
      when 2
        return block.call(self, format)
      else
        return block.call(self, format, opts)
      end
    end
  end
end
