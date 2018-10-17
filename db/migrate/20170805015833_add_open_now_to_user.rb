# frozen_string_literal: true

class AddOpenNowToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :open_now, :boolean, default: false
  end
end
