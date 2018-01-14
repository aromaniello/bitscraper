class CreateTwitterStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :twitter_statuses do |t|
      t.belongs_to :twitter_report
      t.integer :status_index
      t.timestamps
    end
  end
end
