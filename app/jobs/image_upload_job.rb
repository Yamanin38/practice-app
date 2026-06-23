# app/jobs/image_upload_job.rb
class ImageUploadJob < ApplicationJob
  queue_as :default

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

    # 事前にサムネイル画像（Variant）を生成
    image.file.variant(resize_to_fill: [800, 800]).processed
    image.file.variant(resize_to_fill: [400, 400]).processed
  ensure
    File.delete(tempfile_path) if File.exist?(tempfile_path)
    Rails.cache.write("upload_job_#{job_tracking_id}", "completed", expires_in: 5.minutes)
    
    # 🌟 GCの対象になりやすくするため、大きな変数をnilでクリアしておく（ダメ押し）
    compressed_io = nil
    image = nil
    
    # 🌟 メモリ対策：確保したメモリをRubyに早めに回収させる
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

    # 🌟 メモリ解放の準備：使い終わったVipsオブジェクトの参照を切る
    image = nil 

    output
  end
end