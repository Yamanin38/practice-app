class SessionsController < ApplicationController
  def new
    redirect_to root_path if current_user
  end

  def create
    user = User.find_by(username: params[:username])
    if user&.authenticate(params[:password])
    reset_session  # ← これを追加するだけ。古いセッションIDを破棄して新しいIDを発行
      # 【最重要】ここが必ず必要です！
    session[:user_id] = user.id
    session[:session_token] = user.session_token
      redirect_to root_path
    else
      flash.now[:alert] = "ユーザー名またはパスワードが正しくありません"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_back_or_to root_path
  end
end