class Article < ApplicationRecord
  belongs_to :user
  has_many :article_images, dependent: :destroy
  has_many :images, through: :article_images

  validates :title, presence: true
  validates :content, presence: true

  before_save :render_html_content, if: :content_changed?

  private

  def render_html_content
    self.html_content = Kramdown::Document.new(content.to_s).to_html
  end
end