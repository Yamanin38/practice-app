class ImagesController < ApplicationController
  before_action :authenticate_user!, except: []
  before_action :set_image, only: [:destroy]
  before_action :authorize_admin!, only: [:destroy]

  def create
    @image = current_user.images.build

    if params[:file].present?
      compressed = compress_image(params[:file])
      @image.file.attach(
        io: compressed[:io],
        filename: params[:file].original_filename,
        content_type: "image/jpeg"
      )
    end

    if @image.save
      redirect_to gallery_path, notice: "画像をアップロードしました"
    else
      redirect_to gallery_path, alert: "画像のアップロードに失敗しました"
    end
  end

  def destroy
    @image.destroy
    redirect_to gallery_path, notice: "画像を削除しました"
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
