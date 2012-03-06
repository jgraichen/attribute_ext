module AttributeExt
  module HiddenAttributes
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.alias_method_chain :to_xml, :hidden_attrs
      base.alias_method_chain :as_json, :hidden_attrs
      base.alias_method_chain :serializable_hash, :hidden_attrs
    end
  
    module ClassMethods
      # Adds attribute to a blacklist that will be hidden when serializing if optional conditions
      # are true.
      #
      #   class User < ActiveRecord::Base
      #     hide_attributes :password               # always hide
      #     hide_attributes :email, :if => Proc.new { |user| user.hide_email? }
      #     hide_attributes :not_in_json, :only => :json
      #     hide_attributes :except_xml_hash, :except => [:xml, :hash]
      #   end
      # 
      # All given conditions to a rule must be true if attributes should be hidden. Attributes can
      # appear in more than one rule.
      #
      # Options:
      # [:+if+]
      #   Requires a Proc block to be true.
      # 
      # [:+unless+]
      #   Requires a Proc block to be false.
      #
      # [:+only+]
      #   Requires export format to be in given array. A non array object will be converted in to
      #   an array only containing given object.
      #
      # [:+except+]
      #   Requires export format to not be in given array. A non array object will be converted in 
      #   to an array only containing given object.
      # 
      # [:+on_hash+]
      #   By default rules will not be applied when serializing to hash when no :only or :except
      #   rule is specified. If :on_hash is true rule will also apply to hash serialization. If an
      #   :only or :except option is given :on_hash does nothing.
      #
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
        opts = { :except => [], :only => [] }
        opts[:except] += options[:except].is_a?(Array) ? options[:except] : [options[:except]] if options[:except]
        opts[:only]   += options[:only].is_a?(Array)   ? options[:only]   : [options[:only]]   if options[:only]
        opts[:if]     = options[:if] if options[:if].is_a?(Proc)
        opts[:unless] = options[:unless] if options[:unless].is_a?(Proc)
        
        if opts[:except].empty? && opts[:only].empty?
          opts[:except] += [:hash] unless options[:on_hash]
        end
        
        opts
      end
    end
  
    def to_xml_with_hidden_attrs(options = nil, &block) # :nodoc:
      options ||= {}
      options[:except] = hidden_attribute_names(:xml, options)
      options[:hidden_attributes_format] = :xml
      
      to_xml_without_hidden_attrs(options)
    end
  
    def as_json_with_hidden_attrs(options = nil, &block) # :nodoc:
      options ||= {}
      options[:except] = hidden_attribute_names(:json, options)
      options[:hidden_attributes_format] = :json
            
      as_json_without_hidden_attrs(options)
    end
  
    def serializable_hash_with_hidden_attrs(options = nil) # :nodoc:
      options ||= {}
      options[:except] = hidden_attribute_names((options[:hidden_attributes_format] || :hash), options)

      serializable_hash_without_hidden_attrs(options)
    end
    
    # Returns an array with attributes to hide from serialization.
    # 
    # This method should only be used to test own rules without need to run a formatter and
    # validate the generated output. See AttributeExt specs for details.
    # 
    #   hidden_attribute_names :format, :options => :hash
    # 
    def hidden_attribute_names(format, options = {})
      if options[:except].is_a?(Array)
        names = options[:except]
      else
        names = []
        names << options[:except] if options[:except]
      end
  
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
