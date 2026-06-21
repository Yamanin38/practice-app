# app/controllers/images_controller.rb
class ImagesController < ApplicationController
  MAX_UPLOAD_COUNT = 4

  before_action :authenticate_user!, except: []
  before_action :set_image, only: [:destroy]
  before_action :authorize_admin!, only: [:destroy]

  def create
    files = Array(params[:files] || params[:file]).reject(&:blank?).first(MAX_UPLOAD_COUNT)

    if files.empty?
      redirect_to gallery_path, alert: "画像を選択してください", status: :see_other
      return
    end

    files.each do |file|
      # tempfileをリクエスト終了後も残る場所にコピーしてジョブへ渡す
      persistent_path = Rails.root.join("tmp", "uploads", "#{SecureRandom.uuid}_#{file.original_filename}")
      FileUtils.mkdir_p(persistent_path.dirname)
      FileUtils.cp(file.tempfile.path, persistent_path)

      ImageUploadJob.perform_later(current_user.id, persistent_path.to_s, file.original_filename)
    end

    redirect_to gallery_path, notice: "アップロードを受け付けました（反映まで少し時間がかかります）", status: :see_other
  end

  def destroy
    if @image.article_images.exists?
      article_titles = @image.article_images.includes(:article).map { |ai| ai.article.title }
      redirect_to gallery_path, alert: "この画像は以下の活動記録で使用されているため削除できません：#{article_titles.join('、')}", status: :see_other
    else
      @image.destroy
      redirect_to gallery_path, status: :see_other
    end
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end

  def authenticate_user!
    redirect_to login_path unless current_user
  end

  def authorize_admin!
    redirect_to root_path unless current_user&.admin?
  end
end