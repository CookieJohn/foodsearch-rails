class CreateCategories < ActiveRecord::Migration[5.1]
  def up
    create_table :categories do |t|
    	t.integer :facebook_id
    	t.string :facebook_name
      t.timestamps
    end
    add_index :categories, :facebook_id
  end
  def down
  	drop_table :categories
  end
end