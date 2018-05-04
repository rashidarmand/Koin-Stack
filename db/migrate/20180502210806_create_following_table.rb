class CreateFollowingTable < ActiveRecord::Migration[5.2]
  def change
    create_table :following do |t|
      t.integer :primary_id
      t.integer :followed_id
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
