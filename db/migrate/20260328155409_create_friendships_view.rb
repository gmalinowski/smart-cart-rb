class CreateFriendshipsView < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL
        CREATE VIEW user_friends_view AS
        SELECT user_id, friend_id, created_at, updated_at FROM friendships WHERE status = 1
        UNION
        SELECT friend_id, user_id, created_at, updated_at FROM friendships WHERE status = 1
    SQL
    end

  def down
    execute <<-SQL
        DROP VIEW user_friends_view
    SQL
  end
end
