class CreateProfilesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.string :display_name
      t.string :avatar
      t.integer :followers_id
      t.integer :following_id
      t.integer :posts
      t.integer :user_id
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
