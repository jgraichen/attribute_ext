
require 'attribute_ext'

ActiveRecord::Base.send :include, AttributeExt::HiddenAttributes
ActiveRecord::Base.send :include, AttributeExt::SafeAttributes