class ChangePostsTableBack < ActiveRecord::Migration[5.2]
  def change
    change_column :posts, :content, :text
  end
end
