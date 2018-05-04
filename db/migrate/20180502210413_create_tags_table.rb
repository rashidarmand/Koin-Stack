class CreateTagsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :tag
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
