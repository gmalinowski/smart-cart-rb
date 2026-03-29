class CrateFriendships < ActiveRecord::Migration[8.1]
  def change
    create_table :friendships, id: :uuid do |t|
      t.belongs_to :user, foreign_key: { on_delete: :cascade }, null: false, type: :uuid
      t.belongs_to :friend, foreign_key: { to_table: :users, on_delete: :cascade }, null: false, type: :uuid
      t.integer :status, default: 0, null: false
      t.timestamps

      t.index [ :user_id, :friend_id ], unique: true
    end
  end
end
