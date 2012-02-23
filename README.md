
AttributeExt
============

AttributeExt provides additional access control for rails model attributes.
It contains two modules one to protect attributes from mass assignment and one
to hide attributes when serializing models.

Install
-------

Just add the following to your Gemfile

	gem 'attribute_ext'
	
and run `bundle` command.

You can also install AttributeExt as a rails plugin by cloning the repository to
`vendor/plugins`.


AttributeExt::SafeAttributes
----------------------------

Protects attributes from mass assignment using rails mass assignment authorizer.
Also support Proc blocks.

Examples:

Always allow mass assignment for attribute.

	class User < ActiveRecord::Base
	  safe_attributes :attribute
	end

Attributes 'login', 'admin' and 'status' can only be mass assigned if current 
user is an admin.

	class User < ActiveRecord::Base
	  safe_attributes :login, :admin, :status, :if => Proc.new { User.current.admin? }
	end
  
Message text can not be mass assigned when post is locked.

	class Message < ActiveRecord::Base
	  safe_attributes :text, :unless => Proc.new { |msg| msg.locked? }
	end
	
With Rails 3 a role can be given when creating or updating an model. This 
role will also be available in SafeAttributes.

	class User < ActiveRecord::Base
	  safe_attributes :login, :as => :admin
	end
	
or

	class User < ActiveRecord::Base
	  safe_attributes :login, :if => Proc.new { |user,role| role == :admin }
	end
	
Default role and role mapper:

SafeAttributes provides helper for handling roles including a method to set
a new default role as well as a method to map roles to other values. Changes to
role will only affect SafeAttributes and will not be given to Rails 3.1 mass
assignment authorizer.

Set default role that will be used if given role is nil or :default.

	AttributeExt::SafeAttributes.default_role = :new_default
	
Role values can be restricted to specific values using the role mapper.

	AttributeExt::SafeAttributes.role_mapper = Proc.new do |role|
	  [:guest, :user, :admin].include?(role) ? role : :guest
	end
	
or

	AttributeExt::SafeAttributes.role_mapper do |role|
	  [:guest, :user, :admin].include?(role) ? role : :guest
	end

The role mapper is especially usefull if you want the current user model be the
default role.

	AttributeExt::SafeAttributes.role_mapper do |role|
	  role.is_a?(User) ? role : User.current
	end
	
You can perform checks like this now:

	class User < ActiveRecord::Base
	  safe_attribute :email, :if => Proc.new { |user,role| user == role or role.admin? }
	end
	
Now a user can edit his own emails or all email if he is an admin.


AttributeExt::HiddenAttributes
------------------------------

Hides attributes when converting model to XML or JSON. Attributes can be 
dynamically hidden using if or unless Procs. 

Examples:

Only shows API access key when user has API access.

	class User < ActiveRecord::Base
	  hide_attributes :api_access_key, :unless => Proc.new { |user| user.api_access? }
	end
  
Always hide password hash and password salt. Hide email if user do not want to 
show his email.
  
	class User < ActiveRecord::Base
	  hide_attributes :password_hash, :password_salt
	  hide_attributes :email, :if => Proc.new { |user| user.hide_email? }
	end


Additional options are available in if and unless blocks:

Only hide email when serialzing to json.

	class User < ActiveRecord::Base
	  hide_attributes :email, :if => Proc.new { |user, format| format == :json }
	end
	
Simpler format conditions can be defined using :only and :except parameters:

	class User < ActiveRecord::Base
	  hide_attributes :email, :only => :json
	  hide_attributes :special_attr, :except => [:xml, :json]
	end
	
Both parameters accept single attributes and arrays. When :only or :except is 
given the :on_hash option will be ignored.
	
Hide user_id if associated user model will be included. This rule will also
apply when calling serializable_hash.

	class Event < ActiveRecord::Base
	  belongs_to :user
	  hide_attributes :user_id, :on_hash => true, :if => Proc.new { |event, format, opts| opts[:include].include?(:user) }
	end

By default rules *do not* apply when serializing to hash.


Using SafeAttributes with RSpec
-------------------------------

AttributeExt provides a RSpec matcher that can be used to test own safe attributes rules.

Add
	
	require 'attribute_ext/rspec'
	
to your `spec_helper.rb` and use it like this:

	model.should have_no_safe_attributes.as(:guest, 'Guest').and_as(:blocked_user, 'Blocked User')
	model.should have_safe_attributes(:name, :message)
	model.should have_safe_attributes(:attribute).as(:admin, 'Admin')
	
The matcher will generate well formatted descriptions when running RSpec with `-fd`:

	should have no safe attributes as Guest and as Blocked User
	should have safe attributes name, message as default
	should have safe attributes attribute as Admin

License
-------

Copyright (C) 2011 Jan Graichen

AttributeExt is licensed under the Apache License, Version 2.0. 
See LICENSE for more information.
