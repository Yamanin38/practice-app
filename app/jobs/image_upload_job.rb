# app/jobs/image_upload_job.rb
class ImageUploadJob < ApplicationJob
  queue_as :default

  def perform(user_id, tempfile_path, original_filename)
    user = User.find(user_id)
    image = user.images.build

    compressed_io = compress_image(tempfile_path)

    image.file.attach(
      io: compressed_io,
      filename: original_filename,
      content_type: "image/jpeg"
    )

    image.save!
  ensure
    File.delete(tempfile_path) if File.exist?(tempfile_path)
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