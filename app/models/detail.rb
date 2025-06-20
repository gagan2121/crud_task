class Detail < ApplicationRecord
  belongs_to :section
  validates :title, presence: true
  validates :value, presence: true
end
