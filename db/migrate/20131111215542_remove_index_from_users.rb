class RemoveIndexFromUsers < ActiveRecord::Migration
  def change
    remove_index :statuses, :twitter_user_id
    add_index :statuses, :twitter_user_id
  end
end
