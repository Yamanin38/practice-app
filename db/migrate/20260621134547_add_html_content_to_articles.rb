class AddHtmlContentToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :html_content, :text
  end
end
