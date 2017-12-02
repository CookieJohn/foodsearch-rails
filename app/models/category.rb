class Category < ApplicationRecord
  validates :facebook_id, uniqueness: true, presence: true
  validates :facebook_name, presence: true
end
