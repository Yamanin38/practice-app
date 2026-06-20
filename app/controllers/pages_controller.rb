class PagesController < ApplicationController
  def index
  @latest_articles = Article.order(created_at: :desc).limit(10)
  @latest_image = Image.includes(file_attachment: :blob).order(created_at: :desc).first
end

def gallery
    @user = current_user # 一度だけ取得
    # 修正1: N+1対策
    # 画像ファイルだけでなく、紐づく article_images と article も一緒に読み込む
    @images = Image.includes({ article_images: :article }, file_attachment: :blob).ordered_by_date
    @images = @images.by_date(params[:date]) if params[:date].present?
    @images = @images.page(params[:page]).per(24)

    # 修正2: メモリ枯渇対策
    # all ではなく pluck を使い、タイムスタンプ(created_at)だけを抽出してから計算する
    @upload_dates = Image.pluck(:created_at)
                         .map { |time| time.in_time_zone('Tokyo').to_date }
                         .uniq
                         .sort
                         .reverse
  end

  def about
    @team_profile = TeamProfile.singleton
  end

  def update_about
    unless current_user&.admin?
      redirect_to about_path, alert: "権限がありません"
      return
    end

    @team_profile = TeamProfile.singleton
    if @team_profile.update(content: params[:content])
      redirect_to about_path
    else
      redirect_to about_path, alert: "更新に失敗しました"
    end
  end

  def recruitment
    @team_profile = TeamProfile.singleton
  end

  def update_recruitment
    unless current_user&.admin?
      redirect_to recruitment_path, alert: "権限がありません"
      return
    end

    @team_profile = TeamProfile.singleton
    if @team_profile.update(recruitment_content: params[:content])
      redirect_to recruitment_path
    else
      redirect_to recruitment_path, alert: "更新に失敗しました"
    end
  end

  def rules
    @team_profile = TeamProfile.singleton
  end

  def update_rules
    unless current_user&.admin?
      redirect_to rules_path, alert: "権限がありません"
      return
    end

    @team_profile = TeamProfile.singleton
    if @team_profile.update(rules_content: params[:content])
      redirect_to rules_path
    else
      redirect_to rules_path, alert: "更新に失敗しました"
    end
  end

  def contact
  end
end