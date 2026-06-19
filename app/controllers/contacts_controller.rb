require 'net/http'
require 'uri'
require 'json'

class ContactsController < ApplicationController
  # GET /contact
  def new
    # フォームに紐付けるための空のモデルを用意する
    @contact = Contact.new
  end

  # POST /contact
  def create
    # 送信されたデータを使って、新しいContactモデルを作る
    @contact = Contact.new(contact_params)

    # データベースへの保存を試みる
    if @contact.save
      # 保存に成功したらLINE通知用のテキストを組み立てる
      text = "📩 スローンズチームサイトよりお問い合わせがありました\n\n" \
             "【お名前】#{@contact.name}\n" \
             "【メール】#{@contact.email}\n" \
             "【件名】#{@contact.subject}\n" \
             "【メッセージ】\n#{@contact.message}"

      # LINE通知の実行
      send_line_message(text)

      redirect_to contact_path
    else
      # 保存に失敗した場合（エラーがある場合）は、入力画面を再表示
      flash.now[:alert] = "入力内容にエラーがあります。"
      render :new, status: :unprocessable_entity
    end
  end

  private

  # セキュリティ対策: 許可したパラメーター（name, email, subject, message）だけを受け取る
  def contact_params
    params.require(:contact).permit(:name, :email, :subject, :message)
  end

  # --- これ以下のLINE通知メソッドは前回のまま ---
  def send_line_message(text)
    uri = URI.parse("https://api.line.me/v2/bot/message/push")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    
    # ★ 完全な環境変数からの読み込みに変更（直書きテキストは削除）
    channel_token = ENV['LINE_CHANNEL_TOKEN']
    user_id       = ENV['LINE_USER_ID']

    # トークンやIDが空の場合はログに出力して処理を中断する（エラー落ちを防ぐ安全策）
    if channel_token.blank? || user_id.blank?
      Rails.logger.error "LINE通知エラー: 環境変数 LINE_CHANNEL_TOKEN または LINE_USER_ID が設定されていません。"
      return
    end

    request["Authorization"] = "Bearer #{channel_token}"
    request.body = JSON.dump({
      "to" => user_id,
      "messages" => [
        {
          "type" => "text",
          "text" => text
        }
      ]
    })

    req_options = { use_ssl: uri.scheme == "https" }
    Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end
end