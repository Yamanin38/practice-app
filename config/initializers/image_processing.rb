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
    # blobメソッドを使用してファイルをダウンロードする
    download_blob_to_tempfile do |tempfile|
      image = ::Vips::Image.new_from_file(tempfile.path)
      {
        width: image.width,
        height: image.height
      }
    end
  rescue ::Vips::Error
    # Vipsで処理できない場合は親のデフォルト処理（ImageMagick等）へフォールバック
    super
  end
end) if defined?(::Vips)