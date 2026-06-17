class PagesController < ApplicationController
  def index
  @latest_articles = Article.order(created_at: :desc).limit(10)
  @latest_image = Image.includes(file_attachment: :blob).order(created_at: :desc).first
end

def gallery
  @images = Image.includes(file_attachment: :blob).ordered_by_date
  @images = @images.by_date(params[:date]) if params[:date].present?
  @images = @images.page(params[:page]).per(20)
  @upload_dates = Image.all
                      .map { |img| img.created_at.in_time_zone('Tokyo').to_date }
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
      redirect_to about_path, notice: "チーム概要を更新しました"
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
      redirect_to recruitment_path, notice: "入隊案内を更新しました"
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
      redirect_to rules_path, notice: "チーム規約を更新しました"
    else
      redirect_to rules_path, alert: "更新に失敗しました"
    end
  end

  def users
  end

  def contact
  end
end
