class AddColumnsToTeamProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :team_profiles, :recruitment_content, :text
    add_column :team_profiles, :rules_content, :text
  end
end
