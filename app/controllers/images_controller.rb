# app/controllers/images_controller.rb
class ImagesController < ApplicationController
  MAX_UPLOAD_COUNT = 4

  before_action :authenticate_user!, except: []
  before_action :set_image, only: [:destroy]
  before_action :authorize_admin!, only: [:destroy]

  def create
    files = Array(params[:files] || params[:file]).reject(&:blank?).first(MAX_UPLOAD_COUNT)

    if files.empty?
      render json: { error: "画像を選択してください" }, status: :unprocessable_entity
      return
    end

    # 今回のアップロード処理全体を追跡するためのIDを生成
    job_tracking_ids = []

    files.each do |file|
      persistent_path = Rails.root.join("tmp", "uploads", "#{SecureRandom.uuid}_#{file.original_filename}")
      FileUtils.mkdir_p(persistent_path.dirname)
      FileUtils.cp(file.tempfile.path, persistent_path)

      # ジョブごとの追跡IDを生成
      tracking_id = SecureRandom.uuid
      job_tracking_ids << tracking_id
      
      # ジョブに追跡IDを渡す
      ImageUploadJob.perform_later(current_user.id, persistent_path.to_s, file.original_filename, tracking_id)
    end

    # 今回発行したすべての追跡IDをJSに返す（画面遷移はまだしない）
    render json: { tracking_ids: job_tracking_ids }, status: :accepted
  end

  # 【追加】JSから定期的に呼ばれる確認用アクション
  def status
    tracking_ids = params[:tracking_ids] || []
    
    # すべてのジョブのキャッシュが "completed" になっているか確認
    all_completed = tracking_ids.all? do |id|
      Rails.cache.read("upload_job_#{id}") == "completed"
    end

    if all_completed
      render json: { status: 'completed' }
    else
      render json: { status: 'processing' }
    end
  end

  def destroy
    if @image.article_images.exists?
      article_titles = @image.article_images.includes(:article).map { |ai| ai.article.title }
      redirect_to gallery_path, alert: "この画像は以下の活動記録で使用されているため削除できません：#{article_titles.join('、')}", status: :see_other
    else
      @image.file.purge if @image.file.attached?
      @image.destroy
      clean_empty_storage_folders
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

  def clean_empty_storage_folders
    require 'find'
    storage_path = Rails.root.join('storage').to_s
    return unless Dir.exist?(storage_path)

    dirs = []
    Find.find(storage_path) do |path|
      dirs << path if File.directory?(path)
    end

    # 階層の深い順にソートして、空のディレクトリを削除
    dirs.sort_by(&:length).reverse_each do |dir|
      next if dir == storage_path
      begin
        Dir.rmdir(dir) if Dir.empty?(dir)
      rescue SystemCallError
        # 削除できない場合や空でない場合は無視
      end
    end
  end
end