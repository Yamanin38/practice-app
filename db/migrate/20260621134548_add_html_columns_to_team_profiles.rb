class AddHtmlColumnsToTeamProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :team_profiles, :html_content, :text
    add_column :team_profiles, :html_recruitment_content, :text
    add_column :team_profiles, :html_rules_content, :text
  end
end
