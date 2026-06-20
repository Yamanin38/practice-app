class ArticlesController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  # ⭕【修正1】onlyに :show を追加して、詳細ページでも @article を取得できるようにします
  before_action :set_article, only: [:show, :update, :destroy]
  before_action :authorize_owner!, only: [:update]
  before_action :authorize_admin!, only: [:destroy]

  def index
  @articles = Article.includes(:user, images: { file_attachment: :blob }).order(created_at: :desc)
  @all_images = Image.includes(file_attachment: :blob).ordered_by_date
  @article_dates = Article.pluck(:created_at).map { |d| d.in_time_zone('Tokyo').to_date.to_s }.uniq
  if params[:date].present?
    @articles = @articles.where(created_at: Date.parse(params[:date]).all_day)
  end
end

def show
  markdown_text = @article.content || ""
  @html_content = Kramdown::Document.new(markdown_text).to_html
  @all_images = Image.includes(file_attachment: :blob).ordered_by_date
end

  def create
    @article = current_user.articles.build(article_params)
    if @article.save
        attach_images(@article)
        redirect_to articles_path
    else
        @all_images = Image.ordered_by_date
        redirect_to articles_path, alert: "投稿に失敗しました"
    end
  end

  def update
    if @article.update(article_params)
      @article.article_images.destroy_all
      attach_images(@article)
      redirect_to article_path(@article)
    else
      @all_images = Image.ordered_by_date
      redirect_to article_path(@article), alert: "更新に失敗しました"
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_path
  end

  # ── ここから下はコントローラ内部だけで使う秘密のメソッド（private） ──
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
  unless current_user
    redirect_to articles_path
  end
end

def authorize_admin!
  unless current_user&.admin?
    redirect_to articles_path
  end
end
end