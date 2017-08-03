class AddLastSearchToUser < ActiveRecord::Migration[5.1]
  def change
  	add_column :users, :last_search, :json, default: {}
  end
end
