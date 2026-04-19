class CreateListVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :list_visits, id: :uuid do |t|
      t.belongs_to :user, foreign_key: { on_delete: :cascade }, null: false, type: :uuid
      t.belongs_to :shopping_list, foreign_key: { on_delete: :cascade }, null: false, type: :uuid
      t.datetime :visited_at, null: false
      t.integer :interaction_count, null: false, default: 0
      t.timestamps
    end

    add_index :list_visits, [:user_id, :shopping_list_id], unique: true

    add_index :list_visits, [:user_id, :visited_at]
    add_index :list_visits, [:shopping_list_id, :visited_at]
    add_index :list_visits, [:user_id, :interaction_count]
  end
end
