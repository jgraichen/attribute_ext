class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :opts
      
      t.string :attribute_hash
      t.string :attribute_if
      t.string :attribute_if_hash
      t.string :attribute_unless
      t.string :attribute_unless_hash
      t.string :attribute_if_unless
      t.string :attribute_if_format
      t.string :attribute_unless_format
      t.string :attribute_if_opts
      t.string :attribute_unless_opts
      t.string :attribute_only_xml
      t.string :attribute_only_json
      t.string :attribute_only_hash
      t.string :attribute_except_xml
      t.string :attribute_except_json
      t.string :attribute_except_hash
      t.string :attribute_only_xml_txt
      t.string :attribute_except_xml_txt
    end
  end
end
