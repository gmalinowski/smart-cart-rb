class AddBiddirectionalFriendshipUniqueIndex < ActiveRecord::Migration[8.1]
  def change
    add_index :friendships, 'LEAST(user_id::text, friend_id::text), GREATEST(user_id::text, friend_id::text)',
              unique: true, name: "index_unique_symmetric_friendships"
  end
end
