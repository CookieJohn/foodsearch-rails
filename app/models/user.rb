class User < ApplicationRecord

	validates :line_user_id, presence: true
	validates :max_distance, presence: true, numericality: {greater_than_or_equal_to: 500, less_than_or_equal_to: 50000}
	validates :min_score, presence: true, numericality: {greater_than_or_equal_to: 2, less_than_or_equal_to: 5}

	before_validation :set_defaults, on: [:create]
  def set_defaults
    self.max_distance = 500
    self.min_score = 4
  end
end
