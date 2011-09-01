
AttributeExt
============

Copyright (C) 2011 Jan Graichen

AttributeExt provides additional access control for rails model attributes.
It contains two modules one to protect attributes from mass assignment and one
to hide attributes when serializing models.

Changelog
---------

Sep 1, 2011

HiddenAttributes works on included model when serializing to json by hooking 
into serializable_hash now. Therefore it is possible to hide attributes when
serializing to hash via serializable_hash method too. 
But by default rules will not be checked on serializable_hash, you have to 
add `:on_hash => true` to hide_attributes to enabled it for this rule.


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
	
Hide user_id if associated user model will be included. This rule will also
apply when calling serializable_hash.

	class Event < ActiveRecord::Base
	  belongs_to :user
	  hide_attributes :user_id, :on_hash => true, :if => Proc.new { |event, format, opts| opts[:include].include?(:user) }
	end


AttributeExt::SafeAttributes
----------------------------

Protects attributes from mass assignment using rails mass assignment authorizer.
Also support Proc blocks.

Examples:

Never allow mass assignment for attribute.

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
  
License
-------

AttributeExt is licensed under the Apache License, Version 2.0. 
See LICENSE for more information.