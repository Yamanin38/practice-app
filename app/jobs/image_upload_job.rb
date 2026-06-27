# app/jobs/image_upload_job.rb
class ImageUploadJob < ApplicationJob
  queue_as :default

  def perform(user_id, tempfile_path, original_filename, job_tracking_id)
    user = User.find(user_id)
    image = user.images.build

    # クライアント側で圧縮済みのためそのままアタッチ
    image.file.attach(
      io: File.open(tempfile_path),
      filename: original_filename,
      content_type: "image/jpeg"
    )

    image.save!

    # 事前にサムネイル画像（Variant）を生成
    #image.file.variant(resize_to_fill: [800, 800]).processed
    #image.file.variant(resize_to_fill: [400, 400]).processed
  ensure
    File.delete(tempfile_path) if File.exist?(tempfile_path)
    Rails.cache.write("upload_job_#{job_tracking_id}", "completed", expires_in: 5.minutes)
    
    image = nil
    
    # 🌟 メモリ対策：確保したメモリをRubyに早めに回収させる
    GC.start
  end
end