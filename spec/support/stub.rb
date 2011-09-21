
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
  
  def initialize(opts = {})
    @opts = {
      :if => false,
      :unless => true
    }.merge(opts.is_a?(Hash) ? opts : {})
  end
end