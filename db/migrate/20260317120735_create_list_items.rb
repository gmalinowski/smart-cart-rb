class CreateListItems < ActiveRecord::Migration[8.1]
  def change
    create_table :shopping_list_items, id: :uuid do |t|

      t.belongs_to :shopping_list, foreign_key: { on_delete: :cascade, on_update: :cascade }, null: false, type: :uuid

      t.text :name
      t.integer :unit, default: 0
      t.decimal :quantity, precision: 8, scale: 2, default: 0
      t.boolean :checked, default: false, null: false

      t.integer :priority, default: 0, null: false
      t.integer :category, default: 0, null: false

      t.timestamps
    end
  end
end
