# frozen_string_literal: true

class DropCategoriesTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :categories
  end
end
