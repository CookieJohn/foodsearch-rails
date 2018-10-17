# frozen_string_literal: true

class AddGetGoogleResultToUser < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :get_google_result, :boolean, default: false
  end

  def down
    remove_column :users, :get_google_result
  end
end
