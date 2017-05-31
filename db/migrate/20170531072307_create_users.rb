class CreateUsers < ActiveRecord::Migration[5.1]
  def up
    create_table :users do |t|
    	t.string :line_user_id
    	t.integer :max_distance
    	t.float :min_score
    	t.boolean :random_type, default: true

      t.timestamps
    end
    add_index :users, :line_user_id
  end
  def down
  	drop_table :users
  end
end