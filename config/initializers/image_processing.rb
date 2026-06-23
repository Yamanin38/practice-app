# config/initializers/image_processing.rb

# Vipsを利用するための設定
Rails.application.config.image_processing_backend = :vips

if defined?(::Vips)
  # メモリ使用量を抑えるためVipsのキャッシュを完全に無効化する
  ::Vips.cache_set_max(0)
  ::Vips.cache_set_max_mem(0)
  ::Vips.cache_set_max_files(0)
end

ActiveStorage::Analyzer::ImageAnalyzer.prepend(Module.new do
  def metadata
    download_blob_to_tempfile do |tempfile|
      image = ::Vips::Image.new_from_file(tempfile.path)
      
      # 🌟 サイズを変数に退避
      w = image.width
      h = image.height
      
      # 🌟 Vipsオブジェクトの参照を即座に切る
      image = nil
      
      {
        width: w,
        height: h
      }
    end
  rescue ::Vips::Error
    super
  end
end) if defined?(::Vips)