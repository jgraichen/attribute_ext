
require 'attribute_ext/hidden_attributes'
require 'attribute_ext/safe_attributes'
require 'attribute_ext/railtie' if defined?(Rails)

module AttributeExt
  def AttributeExt.setup # :nodoc:
    ActiveRecord::Base.send :include, AttributeExt::HiddenAttributes
    ActiveRecord::Base.send :include, AttributeExt::SafeAttributes
  end
end