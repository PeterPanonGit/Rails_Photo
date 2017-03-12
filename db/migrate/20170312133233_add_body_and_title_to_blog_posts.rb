class AddBodyAndTitleToBlogPosts < ActiveRecord::Migration
  def change
    add_column :blog_posts, :title, :text
    add_column :blog_posts, :body, :text
  end
end
