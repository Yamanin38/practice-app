class Image < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  validates :file, presence: true

  scope :by_date, ->(date) { where("DATE(created_at) = ?", date) if date.present? }
  scope :ordered_by_date, -> { order(created_at: :desc) }
end
