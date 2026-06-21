class TeamProfile < ApplicationRecord
  # team_profiles テーブルには常に1レコードのみ存在する想定
  # content / recruitment_content / rules_content カラムにマークダウン形式のテキストを保存する
  # html_content / html_recruitment_content / html_rules_content には変換済みHTMLをキャッシュする
  # （表示のたびにKramdownで再変換しないようにするための事前計算カラム）

  before_save :render_html_content, if: :content_changed?
  before_save :render_html_recruitment_content, if: :recruitment_content_changed?
  before_save :render_html_rules_content, if: :rules_content_changed?

  def self.singleton
    first_or_create!(content: "")
  end

  private

  def render_html_content
    self.html_content = Kramdown::Document.new(content.to_s).to_html
  end

  def render_html_recruitment_content
    self.html_recruitment_content = Kramdown::Document.new(recruitment_content.to_s).to_html
  end

  def render_html_rules_content
    self.html_rules_content = Kramdown::Document.new(rules_content.to_s).to_html
  end
end