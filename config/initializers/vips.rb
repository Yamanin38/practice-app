# config/initializers/vips.rb

# Ruby-vips はデフォルトで画像処理結果やオブジェクトをメモリにキャッシュします。
# サーバープロセスが長く起動していると、このキャッシュが蓄積してメモリが肥大化するため、
# キャッシュを明示的に無効化してメモリをすぐに解放させるようにします。

if defined?(Vips)
  Vips.cache_set_max(0)
  Vips.cache_set_max_mem(0)
end
