class ApplicationController < ActionController::Base
  helper_method :current_user
  # before_action で一度だけロードしてインスタンス変数に入れる
  before_action :set_current_user_for_views
  before_action :set_user   # ← この行を追加

  def current_user
    # 💡 既に取得済み（@current_userが定義されている）なら、それを返して終了
    return @current_user if defined?(@current_user)
    # セッションに user_id がなければ何もしない
    return nil unless session[:user_id]

    # データベースからユーザーを探す
    user = User.find_by(id: session[:user_id])

    # ユーザーが存在し、かつトークンが一致するかチェック
    if user && session[:session_token] == user.session_token
      @current_user ||= user
    else
      # 不一致（またはユーザーが存在しない）場合はログアウト処理
      session[:user_id] = nil
      session[:session_token] = nil
      @current_user = nil
    end
  end

  # ログにユーザー情報を付与するためのペイロード設定
  def append_info_to_payload(payload)
    super
    payload[:remote_ip] = request.remote_ip
    payload[:user_id] = current_user.id if current_user
    # logrageに表示するためのやつ
    payload[:username] = current_user ? current_user.username : 'guest'
  end

  private

  def set_current_user_for_views
    @current_user_view = current_user
  end

  def set_user
    # ここで一度だけ代入することで、このリクエスト中はこれを使えばOKになる
    @user = current_user 
  end
end