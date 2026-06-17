class HomeController < ApplicationController
  def index
  @latest_articles = Article.order(created_at: :desc).limit(10)
  @latest_image = Image.includes(file_attachment: :blob).order(created_at: :desc).first
end
end