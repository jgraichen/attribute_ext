
require 'attribute_ext/hidden_attributes'
require 'attribute_ext/safe_attributes'

ActiveRecord::Base.send :include, AttributeExt::HiddenAttributes
ActiveRecord::Base.send :include, AttributeExt::SafeAttributes