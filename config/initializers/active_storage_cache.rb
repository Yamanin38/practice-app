# config/initializers/active_storage_cache.rb
Rails.application.config.after_initialize do
  ActiveStorage::Blobs::ProxyController.class_eval do
    after_action :set_cache_headers

    private

    def set_cache_headers
      response.headers["Cache-Control"] = "public, max-age=#{1.year.to_i}, immutable"
    end
  end

  # バリアント（リサイズ済み画像）にも適用
  ActiveStorage::Representations::ProxyController.class_eval do
    after_action :set_cache_headers

    private

    def set_cache_headers
      response.headers["Cache-Control"] = "public, max-age=#{1.year.to_i}, immutable"
    end
  end
end