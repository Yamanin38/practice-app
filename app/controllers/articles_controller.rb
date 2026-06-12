class ArticlesController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  before_action :set_article, only: [:update, :destroy]
  before_action :authorize_owner!, only: [:update, :destroy]

  def index
    @articles = Article.includes(:user, :images).order(created_at: :desc)
    @all_images = Image.includes(:file_attachment).ordered_by_date
  end

  def create
    @article = current_user.articles.build(article_params)
    if @article.save
        attach_images(@article)
        redirect_to articles_path, notice: "記事を投稿しました"
    else
        @all_images = Image.ordered_by_date
        redirect_to articles_path, alert: "投稿に失敗しました"
    end
  end

  def update
    if @article.update(article_params)
      @article.article_images.destroy_all
      attach_images(@article)
      redirect_to articles_path, notice: "記事を更新しました"
    else
      @all_images = Image.ordered_by_date
      redirect_to articles_path, alert: "更新に失敗しました"
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_path, notice: "記事を削除しました"
  end

  private

  def article_params
  params.require(:article).permit(:title, :content, :tags)
    rescue ActionController::ParameterMissing
    params.permit(:title, :content, :tags)
    end

  def attach_images(article)
    image_ids = params[:image_ids].to_a.first(4)
    image_ids.each_with_index do |image_id, index|
      image = Image.find_by(id: image_id)
      article.article_images.create(image: image, position: index) if image
    end
  end

  def set_article
    @article = Article.find(params[:id])
  end

  def authenticate_user!
    redirect_to login_path unless current_user
  end

  def authorize_owner!
    unless current_user&.admin? || @article.user == current_user
      redirect_to articles_path
    end
  end
end