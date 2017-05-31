class ChangeFacebookIdLimitToCategory < ActiveRecord::Migration[5.1]
  def change
  	change_column :categories, :facebook_id, :integer, limit: 8
  end
end
