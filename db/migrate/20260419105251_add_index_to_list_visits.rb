class AddIndexToListVisits < ActiveRecord::Migration[8.1]
  def change
    add_index :list_visits, [:user_id, :visited_at], order: { visited_at: :desc }
  end
end
