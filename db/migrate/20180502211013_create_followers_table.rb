class CreateFollowersTable < ActiveRecord::Migration[5.2]
  def change
    create_table :followers do |t|
      t.integer :primary_id
      t.integer :followed_by_id
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
