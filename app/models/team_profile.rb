class TeamProfile < ApplicationRecord
  # team_profiles テーブルには常に1レコードのみ存在する想定
  # content カラムにマークダウン形式のテキストを保存する

  def self.singleton
    first_or_create!(content: "")
  end
end
