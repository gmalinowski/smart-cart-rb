class CreateGroupShoppingLists < ActiveRecord::Migration[8.1]
  def change
    create_table :group_shopping_lists, id: :uuid do |t|
      t.references :group, null: false, foreign_key: true, type: :uuid
      t.references :shopping_list, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    add_index :group_shopping_lists, [ :group_id, :shopping_list_id ], unique: true
  end
end
