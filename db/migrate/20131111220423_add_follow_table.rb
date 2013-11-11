class AddFollowTable < ActiveRecord::Migration
  def self.up
    add_column :follows, :twitter_follower_id, :integer
    change_column :follows, :twitter_follower_id, :integer, null: false
    add_column :follows, :twitter_followee_id, :integer
    change_column :follows, :twitter_followee_id, :integer, null: false

    add_index :follows, :twitter_follower_id
    add_index :follows, :twitter_followee_id
    add_index :follows, [:twitter_follower_id, :twitter_followee_id], unique: true
  end

  def self.down
    remove_column :follows, :twitter_follower_id
    remove_column :follows, :twitter_followee_id
  end

end
