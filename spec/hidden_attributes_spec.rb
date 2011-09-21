
require 'spec_helper'

describe AttributeExt::HiddenAttributes do
  
  it 'can hide attributes always' do
    user = User.new
    
    user.hidden_attribute_names(:format).should include('attribute')
  end
  
  it 'can hide attributes using an if condition' do
    user = User.new
    user.hidden_attribute_names(:format).should_not include('attribute_if')
    
    user = User.new :if => true
    user.hidden_attribute_names(:format).should include('attribute_if')
  end
  
  it 'can hide attributes using an unless condition' do
    user = User.new
    user.hidden_attribute_names(:format).should_not include('attribute_unless')
    
    user = User.new :unless => false
    user.hidden_attribute_names(:format).should include('attribute_unless')
  end
  
  it 'can hide attributes using an if and unless condition' do
    user = User.new
    user.hidden_attribute_names(:format).should_not include('attribute_if_unless')
    
    user = User.new :if => true
    user.hidden_attribute_names(:format).should_not include('attribute_if_unless')
    
    user = User.new :unless => false
    user.hidden_attribute_names(:format).should_not include('attribute_if_unless')
    
    user = User.new :unless => false, :if => true
    user.hidden_attribute_names(:format).should include('attribute_if_unless')
  end
  
  it 'can hide attributes using an if condition with format argument' do
    user = User.new
    user.hidden_attribute_names(:not_format).should_not include('attribute_if_format')
    user.hidden_attribute_names(:format).should include('attribute_if_format')
  end
  
  it 'can hide attributes using an unless condition with format argument' do
    user = User.new
    user.hidden_attribute_names(:format).should_not include('attribute_unless_format')
    user.hidden_attribute_names(:not_format).should include('attribute_unless_format')
  end
  
  it 'can hide attributes using an if condition with options argument' do
    user = User.new
    user.hidden_attribute_names(:format, {:hide => true}).should_not include('attribute_if_opts')
    user.hidden_attribute_names(:format, {:hide => false}).should include('attribute_if_opts')
  end
  
  it 'can hide attributes using an unless condition with options argument' do
    user = User.new
    user.hidden_attribute_names(:format, {:hide => false}).should_not include('attribute_unless_opts')
    user.hidden_attribute_names(:format, {:hide => true}).should include('attribute_unless_opts')
  end
  
  it 'only applies rules to hash if wanted' do
    user = User.new
    user.hidden_attribute_names(:hash).should_not include('attribute')
    user.hidden_attribute_names(:hash).should include('attribute_hash')
  end
  
  it 'only applies rules to hash if wanted (if condition)' do
    user = User.new :if => true
    user.hidden_attribute_names(:hash).should_not include('attribute_if')
    user.hidden_attribute_names(:hash).should include('attribute_if_hash')
  end
  
  it 'only applies rules to hash if wanted (unless condition)' do
    user = User.new :unless => false
    user.hidden_attribute_names(:hash).should_not include('attribute_unless')
    user.hidden_attribute_names(:hash).should include('attribute_unless_hash')
  end
end