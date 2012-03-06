
require File.dirname(__FILE__) + '/spec_helper'

describe AttributeExt::SafeAttributes do
  
  it 'uses mass assignment authorizer' do
    user = User.new
    
    user.safe_attributes_authorizer.should include('always')
  end

  it 'should support attr_accessible' do
    user = User.new
    user.safe_attributes_authorizer.should include('opts')
  end
  
  it 'uses mass assignment authorizer with role' do
    user = User.new
    
    user.safe_attributes_authorizer(:admin).should include('admin_role')
  end
  
  it 'can whitelist attributes' do
    user = User.new
    
    user.safe_attributes_authorizer.should include('always')
  end
  
  it 'can whitelist attributes using an if condition' do
    user = User.new
    user.safe_attributes_authorizer.should_not include('attribute_if')
    
    user = User.new :opts => { :if => true }
    user.safe_attributes_authorizer.should include('attribute_if')
  end
  
  it 'can whitelist attributes using an unless condition' do
    user = User.new
    user.safe_attributes_authorizer.should_not include('attribute_unless')
    
    user = User.new :opts => { :unless => false }
    user.safe_attributes_authorizer.should include('attribute_unless')
  end
  
  it 'can whitelist attributes using an if and an unless condition' do
    user = User.new
    user.safe_attributes_authorizer.should_not include('attribute_if_unless')
    user = User.new :opts => { :if => true }
    user.safe_attributes_authorizer.should_not include('attribute_if_unless')
    user = User.new :opts => { :unless => false }
    user.safe_attributes_authorizer.should_not include('attribute_if_unless')
    
    user = User.new :opts => { :if => true, :unless => false }
    user.safe_attributes_authorizer.should include('attribute_if_unless')
  end
  
  it 'can whitelist attributes checking role in if condition' do
    user = User.new
    user.safe_attributes_authorizer(:default).should_not include('attribute_if_admin')
    user = User.new
    user.safe_attributes_authorizer(:admin).should include('attribute_if_admin')
  end
  
  it 'can whitelist attributes checking role in unless condition' do
    user = User.new
    user.safe_attributes_authorizer(:default).should include('attribute_unless_admin')
    user = User.new
    user.safe_attributes_authorizer(:admin).should_not include('attribute_unless_admin')
  end
  
  it 'can provide a global default role' do
    AttributeExt::SafeAttributes.default_role = :new_default
    AttributeExt::SafeAttributes.default_role.should == :new_default
    User.new.safe_attributes_authorizer.should include("new_default")
  end
  
  context '#role_mapper' do
    it 'is nil by default' do
      AttributeExt::SafeAttributes.role_mapper.should be_nil
    end
    
    it 'accept Procs' do
      proc = Proc.new { |role| role }
      AttributeExt::SafeAttributes.role_mapper = proc
      AttributeExt::SafeAttributes.role_mapper.should equal(proc)
    end
    
    it 'accept nil' do
      AttributeExt::SafeAttributes.role_mapper = nil
      AttributeExt::SafeAttributes.role_mapper.should be_nil
    end
    
    it 'accept blocks' do
      AttributeExt::SafeAttributes.role_mapper { |role| role }
      AttributeExt::SafeAttributes.role_mapper.should be_an Proc
    end
  
    it 'maps role according to given Proc' do
      AttributeExt::SafeAttributes.role_mapper = Proc.new do |role|
        [:guest, :user, :admin].include?(role) ? role : :guest
      end
      
      User.new.safe_attributes_role.should == :guest
      User.new.safe_attributes_role(:user).should == :user
      User.new.safe_attributes_role(:admin).should == :admin
      User.new.safe_attributes_role(:heinz).should == :guest
    end
    
    it 'gives role to rules' do
      AttributeExt::SafeAttributes.role_mapper = Proc.new do |role|
        [:guest, :user, :admin].include?(role) ? role : :guest
      end
      
      User.new.safe_attributes_authorizer.should include('role_mapper_guest')
      User.new.safe_attributes_authorizer.should_not include('role_mapper_user')
      User.new.safe_attributes_authorizer.should_not include('role_mapper_admin')
      
      User.new.safe_attributes_authorizer(:user).should_not include('role_mapper_guest')
      User.new.safe_attributes_authorizer(:user).should include('role_mapper_user')
      User.new.safe_attributes_authorizer(:user).should_not include('role_mapper_admin')
      
      User.new.safe_attributes_authorizer(:admin).should_not include('role_mapper_guest')
      User.new.safe_attributes_authorizer(:admin).should_not include('role_mapper_user')
      User.new.safe_attributes_authorizer(:admin).should include('role_mapper_admin')
    end
  end
end