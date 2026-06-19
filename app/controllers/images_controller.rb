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

    saved_images = []
    failed = false

    files.each do |file|
      image = current_user.images.build
      compressed = compress_image(file)
      image.file.attach(
        io: compressed[:io],
        filename: file.original_filename,
        content_type: "image/jpeg"
      )

      if image.save
        saved_images << image
      else
        failed = true
      end
    end

    if failed
      redirect_to gallery_path, alert: "一部の画像のアップロードに失敗しました（#{saved_images.size}/#{files.size}枚成功）", status: :see_other
    else
      redirect_to gallery_path, status: :see_other
    end
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

  def compress_image(file)
  image = Vips::Image.new_from_file(file.tempfile.path)
  
  # 高さが720pxを超える場合は720pにリサイズ
  if image.height > 720
    scale = 720.0 / image.height
    image = image.resize(scale)
  end
  
  output = StringIO.new
  image.jpegsave_buffer(Q: 55).tap do |buf|
    output.write(buf)
    output.rewind
  end
  { io: output }
end

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