class Image < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  validates :file, presence: true

  # app/models/image.rb
  scope :by_date, ->(date) {
    where(created_at: Time.zone.parse(date).all_day) if date.present?
  }
  scope :ordered_by_date, -> { order(created_at: :desc) }
end
