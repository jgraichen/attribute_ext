
require 'attribute_ext/hidden_attributes'
require 'attribute_ext/safe_attributes'
require 'attribute_ext/railtie' if defined?(Rails)

module AttributeExt
  def self.setup # :nodoc:
    ActiveRecord::Base.send :include, AttributeExt::HiddenAttributes
    ActiveRecord::Base.send :include, AttributeExt::SafeAttributes
  end

  def self.activemodel_3_0?
    ::ActiveModel::VERSION::MAJOR == 3 and
    ::ActiveModel::VERSION::MINOR == 0
  end
end