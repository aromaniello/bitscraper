class CreateBitcointalkUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :bitcointalk_users do |t|
      t.string :twitter_url
      t.timestamps
    end
  end
end
