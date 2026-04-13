class ModifyUserFriendsView < ActiveRecord::Migration[8.1]
  def up
    execute 'DROP VIEW IF EXISTS user_friends_view'
    execute <<-SQL
      CREATE VIEW user_friends_view AS
      SELECT id AS friendship_id, user_id, friend_id, true AS is_sender FROM friendships
      UNION
      SELECT id AS friendship_id, friend_id, user_id, false AS is_sender FROM friendships
    SQL
  end

  def down
    execute 'DROP VIEW IF EXISTS user_friends_view'
  end
end
