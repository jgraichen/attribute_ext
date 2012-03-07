module AttributeExt
  module SafeAttributes
    # Returns default role used by SafeAttributes.
    # See SafeAttributes#default_role= for how to specify a default role.
    def SafeAttributes.default_role
      @default_role || :default
    end
    
    # Sets SafeAttributes default role that will be used when given role
    # is a nil value or the :default role. The SafeAttributes default role will
    # only affect this extension and will not be given to Rails 3.1 mass 
    # assignment authorizer.
    def SafeAttributes.default_role=(role)
      @default_role = role
    end
    
    # Returns current role mapper block or sets role mapper if an block is
    # given. By default no role mapper is active.
    #
    #   AttributeExt::SafeAttributes.role_mapper do |role|
    #     [:guest, :user, :admin].include?(role) ? role : :guest
    #   end
    #
    def SafeAttributes.role_mapper(&block)
      self.role_mapper = block if block
      @role_mapper
    end
    
    # Sets current role mapper to given Proc or removes role mapper if
    # a nil value is given. Any other value will do nothing.
    # 
    #   AttributeExt::SafeAttributes.role_mapper = Proc.new do |role|
    #     [:guest, :user, :admin].include?(role) ? role : :guest
    #   end
    # 
    # See SafeAttributes#role_mapper for an short way to set a role mapper.
    def SafeAttributes.role_mapper=(role_mapper)
      @role_mapper = role_mapper if role_mapper.is_a?(Proc)
      @role_mapper = nil if role_mapper.nil?
    end
    
    def self.included(base)  # :nodoc:
      base.extend(ClassMethods)
      base.alias_method_chain :mass_assignment_authorizer, :safe_attrs
    end

    
    module ClassMethods
      # Adds a whitelist rule that allows mass assignment for given attributes
      # based on given optional conditions.
      # 
      #   class User < ActiveRecord::Base
      #     # always mass assignable
      #     safe_attributes :name, :email
      #     # only when new record
      #     safe_attributes :login, :if => Proc.new { |user| user.new_record? }
      #     # only own password or as admin
      #     safe_attributes :password, :if => Proc.new { |user,role| user == role }
      #     safe_attributes :password, :as => :admin
      #   end
      # 
      # All given conditions for one rule must be true to allow mass 
      # assignment for given attributes. Attributes can be added in more than
      # one rule to allow alternatives (like password above).
      # 
      # Available Options:
      # [:+as+]
      #   Attributes will be assignable if mass assignment role is equal (==) given object.
      #
      # [:+if+]
      #   Makes attributes assignable if given Proc block returns true.
      #
      # [:+unless+]
      #   Attributes cannot be mass assigned if Proc block evaluates to true.
      #
      # The :if and :unless options must be Proc block that will be executed each time the 
      # mass assignment authorizer is called and they are called with current 
      # model and role as parameters.
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
        opts[:if]     = options[:if] if options[:if].is_a?(Proc) or options[:if].is_a?(Symbol)
        opts[:unless] = options[:unless] if options[:unless].is_a?(Proc) or options[:unless].is_a?(Symbol)
        opts
      end
    end

    def mass_assignment_authorizer_with_safe_attrs(role = nil) # :nodoc:
      safe_attributes_authorizer role
    end

    def safe_attributes_authorizer(role = nil)
      if AttributeExt.activemodel_3_0?
        attrs      = safe_attribute_names
        authorizer = mass_assignment_authorizer_without_safe_attrs
      else
        attrs      = safe_attribute_names(role)
        authorizer = mass_assignment_authorizer_without_safe_attrs(role)
      end

      if authorizer.kind_of?(::ActiveModel::MassAssignmentSecurity::WhiteList)
        return authorizer + attrs
      else
        return ::ActiveModel::MassAssignmentSecurity::WhiteList.new attrs
      end
    end
    
    # Returns new mapped role for given role used by SafeAttributes.
    # This method should only be used to test own role mapper implementations without need for a 
    # full application. See AttributeExt specs for details.
    # 
    # See +role_mapper+ method in SafeAttributes module for how to set a role mapper.
    def safe_attributes_role(role = nil)
      return AttributeExt::SafeAttributes.role_mapper.call(role) unless AttributeExt::SafeAttributes.role_mapper.nil?
      return AttributeExt::SafeAttributes.default_role if role.nil? or role == :default
      role
    end

    # Returns an array with attributes allowed to be mass assigned by given role. Role will be
    # mapped before given to rules.
    # This method should only be used to test own rules without need to create lots of records
    # to test different situations. See AttributeExt specs for details.
    def safe_attribute_names(role = nil)
      role = safe_attributes_role(role)
      
      names = []
      self.class.safe_attributes.collect do |attrs, options|
        next unless options[:as].empty? or options[:as].include?(role)
        next unless options[:if].nil? or safe_attrs_call(options[:if], role)
        next unless options[:unless].nil? or !safe_attrs_call(options[:unless], role)

        names += attrs.collect(&:to_s)
      end
      names.uniq
    end
    
    private
    def safe_attrs_call(block_or_sym, role)
      return safe_attrs_call_block(block_or_sym, role) if block_or_sym.is_a?(Proc)
      return self.send block_or_sym
    end

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
