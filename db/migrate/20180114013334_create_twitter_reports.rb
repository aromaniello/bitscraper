class CreateTwitterReports < ActiveRecord::Migration[5.1]
  def change
    create_table :twitter_reports do |t|
      t.belongs_to :bitcointalk_user
      t.datetime :last_edited
      t.integer :week
      t.timestamps
    end
  end
end
