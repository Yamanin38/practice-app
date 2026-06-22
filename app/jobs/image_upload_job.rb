# app/jobs/image_upload_job.rb
class ImageUploadJob < ApplicationJob
  queue_as :default

  # ジョブの追跡ID（job_id）を受け取れるようにします
  def perform(user_id, tempfile_path, original_filename, job_tracking_id)
    user = User.find(user_id)
    image = user.images.build

    compressed_io = compress_image(tempfile_path)

    image.file.attach(
      io: compressed_io,
      filename: original_filename,
      content_type: "image/jpeg"
    )

    image.save!
     # 🌟 ここを追記：ジョブの中で事前にサムネイル画像（Variant）を生成しておく
    image.file.variant(resize_to_fill: [800, 800]).processed
    image.file.variant(resize_to_fill: [400, 400]).processed
  ensure
    File.delete(tempfile_path) if File.exist?(tempfile_path)
    
    # 【追加】処理が完了（または失敗）したら、キャッシュに完了フラグを書き込む
    # 有効期限を短く（例：5分）設定しておきます
    Rails.cache.write("upload_job_#{job_tracking_id}", "completed", expires_in: 5.minutes)
    
    # 🌟 メモリ対策：C拡張(Vips)が確保したメモリをRubyに早めに回収させる
    GC.start
  end

  private

  def compress_image(path)
    image = Vips::Image.new_from_file(path)
    if image.height > 720
      scale = 720.0 / image.height
      image = image.resize(scale)
    end

    output = StringIO.new
    image.jpegsave_buffer(Q: 55).tap do |buf|
      output.write(buf)
      output.rewind
    end
    output
  end
end