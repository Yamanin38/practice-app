# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store,
  key: '_app_session',
  secure: Rails.env.production?,   # HTTPS 経由のみ送信
  httponly: true,                   # JS からアクセス不可
  same_site: :lax                   # CSRF 対策の補強