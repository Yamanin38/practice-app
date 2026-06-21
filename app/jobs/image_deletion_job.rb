# app/jobs/image_deletion_job.rb
class ImageDeletionJob < ApplicationJob
  queue_as :default

  def perform(image_id)
    image = Image.find_by(id: image_id)
    return unless image

    # ジョブ実行時点で記事に紐付けられていた場合は安全のため削除しない
    # （リクエスト〜ジョブ実行の間に別の記事へ追加されたケースを想定）
    return if image.article_images.exists?

    image.destroy
  end
end
