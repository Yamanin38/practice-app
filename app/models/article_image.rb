class ArticleImage < ApplicationRecord
  belongs_to :article
  belongs_to :image
end