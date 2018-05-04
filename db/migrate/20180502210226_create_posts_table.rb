class CreatePostsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.string :image
      t.string :video
      t.integer :profile_id
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
