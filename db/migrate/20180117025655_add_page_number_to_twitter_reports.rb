class AddPageNumberToTwitterReports < ActiveRecord::Migration[5.1]
  def change
  	add_column :twitter_reports, :page_number, :integer
  end
end
