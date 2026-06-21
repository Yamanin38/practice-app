# 1. スレッド数を「1〜2」に制限（Pi 3Bの1GB RAMでは5スレッドは耐えられません）
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 2 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

rails_env = ENV.fetch("RAILS_ENV") { "development" }

# 2. 本番環境では必ずプロセス数を「0」（プロセスを増やさないシングルモード）にする
if rails_env == "production"
  workers 0
end

# 3. ポート3000で通信（Docker環境ではこれが一番シンプルでトラブルが起きません）
port ENV.fetch("PORT") { 3000 }

environment rails_env
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }
plugin :tmp_restart
plugin :solid_queue
