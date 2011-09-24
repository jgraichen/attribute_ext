
class User < ActiveRecord::Base
  
  attr_accessor :opts
  
  hide_attributes :attribute
  hide_attributes :attribute_hash, :on_hash => true
  
  hide_attributes :attribute_if, 
    :if => Proc.new { |user| user.opts[:if] }
  hide_attributes :attribute_if_hash, :on_hash => true, 
    :if => Proc.new { |user| user.opts[:if] }
  
  hide_attributes :attribute_unless, 
    :unless => Proc.new { |user| user.opts[:unless] }
  hide_attributes :attribute_unless_hash, :on_hash => true, 
    :unless => Proc.new { |user| user.opts[:unless] }
  
  hide_attributes :attribute_if_unless, 
    :if => Proc.new { |user| user.opts[:if] } , 
    :unless => Proc.new { |user| user.opts[:unless] }
    
  hide_attributes :attribute_if_format, 
    :if => Proc.new { |u,format| format == :format }
  
  hide_attributes :attribute_unless_format, 
    :unless => Proc.new { |u,format| format == :format }
  
  hide_attributes :attribute_if_opts, 
    :if => Proc.new { |u,format,opts| opts[:hide] == false }
  
  hide_attributes :attribute_unless_opts, 
    :unless => Proc.new { |u,format,opts| opts[:hide] == false }
    
  hide_attributes :attribute_only_xml, :only => :xml
  hide_attributes :attribute_only_json, :only => :json
  hide_attributes :attribute_only_hash, :only => :hash
  hide_attributes :attribute_except_xml, :except => :xml
  hide_attributes :attribute_except_json, :except => :json
  hide_attributes :attribute_except_hash, :except => :hash
  hide_attributes :attribute_only_xml_txt, :only => [:xml, :txt]
  hide_attributes :attribute_except_xml_txt, :except => [:xml, :txt]
  
  safe_attributes :always
  safe_attributes :admin_role, :as => :admin
  safe_attributes :attribute_if, 
    :if => Proc.new { |user| user.opts[:if] }
  safe_attributes :attribute_unless, 
    :unless => Proc.new { |user| user.opts[:unless] }
  safe_attributes :attribute_if_unless, 
    :if => Proc.new { |user| user.opts[:if] }, 
    :unless => Proc.new { |user| user.opts[:unless] }
  safe_attributes :attribute_if_admin,
    :if => Proc.new { |user,role| role == :admin}
  safe_attributes :attribute_unless_admin,
    :unless => Proc.new { |user,role| role == :admin}
  safe_attributes :new_default, :as => :new_default
  
  def initialize(opts = {})
    @opts = {
      :if => false,
      :unless => true
    }.merge(opts.is_a?(Hash) ? opts : {})
  end
end
