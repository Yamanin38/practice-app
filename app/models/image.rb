class Image < ApplicationRecord
  belongs_to :user
  has_one_attached :file
  has_many :article_images, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :articles, through: :article_images   # ← この行を追加

  validates :file, presence: true

  scope :by_date, ->(date) {
    where(created_at: Time.zone.parse(date).all_day) if date.present?
  }
  scope :ordered_by_date, -> { order(created_at: :desc) }
end