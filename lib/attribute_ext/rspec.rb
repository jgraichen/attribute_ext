
if defined?(ActiveModel)
  # Checks if a model has certain safe attributes.
  #
  # :call-seq:
  # model.should have_safe_attributes(attribute1, attribute2 ...).as(role, name).and_as(role2, name2)
  #
  # model should be an instance of ActiveRecord::Base
  # attribute should be the model attribute name as string or symbol
  # role may be a role identifier
  # name may be a name for role used for description
  #
  # Examples
  #
  #   user.should have_no_safe_attributes()
  #   user.should have_safe_attributes(:email).as(:self, 'himself')
  #   user.should have_safe_attributes(:login, :email).as(:admin, 'Admin).and_as(:system, 'System')
  #
  # #as and #and_as can be used equally. #have_no_safe_attributes is 
  # an alias for #have_safe_attributes with no parameters.
  #
  # have_safe_attributes should not be used with should_not.
  #
  def have_safe_attributes(*attributes)
    SafeAttributesMatcher.new(attributes)
  end
  
  def have_no_safe_attributes # :nodoc:
    have_safe_attributes
  end
end

class SafeAttributesMatcher # :nodoc:
  def initialize(attributes)
    @attributes = attributes.map(&:to_s)
    @roles = []
    @safe  = []
  end
  
  def as(role, name = nil)
    @roles << [role, name]
    self
  end
  alias_method :and_as, :as

  def matches?(model)
    (@roles || [nil, nil]).each do |role, name|
      @role = role
      @name = name
      @safe = model.safe_attribute_names(role)
      
      @missing = (@attributes-@safe)
      @extra   = (@safe-@attributes)
      
      return false if @missing.any? or @extra.any?
    end
    true
  end

  def does_not_match?(model)
    !matches?(model)
  end

  def failure_message_for_should
    output  = "expected safe attributes: #{@attributes.inspect}\n" +
              "but has safe attributes:  #{@safe.inspect}\n"
             
    output += "missing elements are:     #{@missing.inspect}\n" if @missing.any?
    output += "extra elements are:       #{@extra.inspect}\n"   if @extra.any?
    output += "as #{@name || @role.to_s}" unless @role.nil?
    
    output
  end

  def failure_message_for_should_not
    "WARNING: have_safe_attributes should not be used with should_not."
  end

  def description
    roles = @roles.any? ? (@roles || []).map { |r,n| n||r.to_s }.join(' and as ') : 'default'
    if @attributes.any?
      "have safe attributes #{@attributes.join(', ')} as #{roles}" 
    else
      "have no safe attributes as #{roles}" 
    end
  end
end
