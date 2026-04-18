class CreateListVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :list_visits, id: :uuid do |t|
      t.belongs_to :user, foreign_key: { on_delete: :cascade }, null: false, type: :uuid
      t.belongs_to :shopping_list, foreign_key: { on_delete: :cascade }, null: false, type: :uuid
      t.timestamps
    end

    add_index :list_visits, [:user_id, :created_at]
    add_index :list_visits, [:shopping_list_id, :created_at]

  end
end
