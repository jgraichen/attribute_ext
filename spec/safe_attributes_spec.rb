
require File.dirname(__FILE__) + '/spec_helper'

describe AttributeExt::HiddenAttributes do
  
  it 'uses mass assignment authorizer' do
    user = User.new
    
    user.mass_assignment_authorizer.should include('always_there')
  end
  
  it 'uses mass assignment authorizer with role' do
    user = User.new
    
    user.mass_assignment_authorizer(:admin).should include('admin_role')
  end
  
  it 'can whitelist attributes' do
    user = User.new
    
    user.mass_assignment_authorizer.should include('always')
  end
  
  it 'can whitelist attributes using an if condition' do
    user = User.new
    user.mass_assignment_authorizer.should_not include('attribute_if')
    
    user = User.new :if => true
    user.mass_assignment_authorizer.should include('attribute_if')
  end
  
  it 'can whitelist attributes using an unless condition' do
    user = User.new
    user.mass_assignment_authorizer.should_not include('attribute_unless')
    
    user = User.new :unless => false
    user.mass_assignment_authorizer.should include('attribute_unless')
  end
  
  it 'can whitelist attributes using an if and an unless condition' do
    user = User.new
    user.mass_assignment_authorizer.should_not include('attribute_if_unless')
    user = User.new :if => true
    user.mass_assignment_authorizer.should_not include('attribute_if_unless')
    user = User.new :unless => false
    user.mass_assignment_authorizer.should_not include('attribute_if_unless')
    
    user = User.new :if => true, :unless => false
    user.mass_assignment_authorizer.should include('attribute_if_unless')
  end
  
  it 'can whitelist attributes checking role in if condition' do
    user = User.new
    user.mass_assignment_authorizer(:default).should_not include('attribute_if_admin')
    user = User.new
    user.mass_assignment_authorizer(:admin).should include('attribute_if_admin')
  end
  
  it 'can whitelist attributes checking role in unless condition' do
    user = User.new
    user.mass_assignment_authorizer(:default).should include('attribute_unless_admin')
    user = User.new
    user.mass_assignment_authorizer(:admin).should_not include('attribute_unless_admin')
  end
end