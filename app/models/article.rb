class Article < ApplicationRecord
  belongs_to :user
  has_many :article_images, dependent: :destroy
  has_many :images, through: :article_images

  validates :title, presence: true
  validates :content, presence: true
end