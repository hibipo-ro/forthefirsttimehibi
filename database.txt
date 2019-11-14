class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t| 
      t.string :name
      t.string :password
      t.text :profile_image_url
    end
    create_table :posts do |p| 
      p.integer :user_id
      p.text :image_url
      p.text :content
    end 
    create_table :likes do |l| 
      l.integer :user_id
      l.integer :post_id
    end
    create_table :follows do |f| 
      f.integer :from_user_id
      f.integer :to_user_id
    end
    create_table :comments do |c| 
      c.integer :post_id
      c.integer :user_id
      c.text :comment
    end
  end
end
