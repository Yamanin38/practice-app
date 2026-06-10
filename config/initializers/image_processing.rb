# Configure image processing to use libvips
Rails.application.config.image_processing_backend = :vips

# Configure the image_processing gem to use vips
ActiveStorage::Analyzer::ImageAnalyzer.prepend(Module.new do
  def metadata
    return super unless file_path

    download_blob_to_tempfile do |tempfile|
      image = ::Vips::Image.new_from_file(tempfile.path)
      {
        width: image.width,
        height: image.height
      }
    end
  rescue ::Vips::Error
    super
  end
end) if defined?(::Vips)
