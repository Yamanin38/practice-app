# config/initializers/image_processing.rb

require "image_processing/mini_magick"

Rails.application.config.image_processing_backend = :mini_magick

ActiveStorage::Analyzer::ImageAnalyzer.prepend(Module.new do
  def metadata
    download_blob_to_tempfile do |tempfile|
      image = ::MiniMagick::Image.open(tempfile.path)

      w = image.width
      h = image.height

      image = nil

      {
        width: w,
        height: h
      }
    end
  rescue ::MiniMagick::Error
    super
  end
end)