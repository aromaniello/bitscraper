class CreateBitcointalkUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :bitcointalk_users do |t|
      t.string :username
      t.string :twitter_user_url
      t.timestamps
    end
  end
end
