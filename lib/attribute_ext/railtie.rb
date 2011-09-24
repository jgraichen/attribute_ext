
module AttributeExt
  class Railtie < Rails::Railtie # :nodoc:
    initializer 'attribute_ext' do |app|
      ActiveSupport.on_load :active_record do
        AttributeExt.setup
      end
    end
  end
end