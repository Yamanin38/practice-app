class HomeController < ApplicationController
  def index
    # 最新記事を日時の降順で最大10件取得
    @latest_articles = Article.order(created_at: :desc).limit(10)

    # 最新の画像を日時の降順で1件取得（ファイルのアタッチメントも含む）
    @latest_image = Image.order(created_at: :desc).with_attached_file.first
  end
end