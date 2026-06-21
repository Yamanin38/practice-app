# app/jobs/line_notification_job.rb
require 'net/http'
require 'uri'
require 'json'

class LineNotificationJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(text)
    channel_token = ENV["LINE_CHANNEL_TOKEN"]
    user_id       = ENV["LINE_USER_ID"]

    if channel_token.blank? || user_id.blank?
      Rails.logger.error "LINE通知エラー: 環境変数 LINE_CHANNEL_TOKEN または LINE_USER_ID が設定されていません。"
      return
    end

    uri = URI.parse("https://api.line.me/v2/bot/message/push")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{channel_token}"
    request.body = JSON.dump({
      "to" => user_id,
      "messages" => [{ "type" => "text", "text" => text }]
    })

    req_options = { use_ssl: uri.scheme == "https" }
    Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      response = http.request(request)
      raise "LINE API error: #{response.code} #{response.body}" unless response.is_a?(Net::HTTPSuccess)
    end
  end
end