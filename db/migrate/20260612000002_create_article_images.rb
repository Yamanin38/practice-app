class CreateArticleImages < ActiveRecord::Migration[7.1]
  def change
    create_table :article_images do |t|
      t.references :article, null: false, foreign_key: true
      t.references :image, null: false, foreign_key: true
      t.integer :position, default: 0

      t.timestamps
    end
  end
end