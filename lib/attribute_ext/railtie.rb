
module AttributeExt
  class Railtie < Rails::Railtie
    initializer 'attribute_ext' do |app|
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.send :include, AttributeExt::HiddenAttributes
        ActiveRecord::Base.send :include, AttributeExt::SafeAttributes::ModelPatch
      end
    end
  end
end