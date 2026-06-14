class CreateTeamProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :team_profiles do |t|
      t.text :content

      t.timestamps
    end
  end
end
