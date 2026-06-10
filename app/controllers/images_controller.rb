class ImagesController < ApplicationController
  before_action :authenticate_user!, except: []
  before_action :set_image, only: [:destroy]
  before_action :authorize_admin!, only: [:destroy]

  def create
    @image = current_user.images.build
    @image.file.attach(params[:file])

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
