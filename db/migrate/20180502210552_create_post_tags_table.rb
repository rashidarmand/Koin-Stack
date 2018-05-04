class CreatePostTagsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :post_tags do |t|
      t.integer :post_id
      t.integer :tag_id
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
