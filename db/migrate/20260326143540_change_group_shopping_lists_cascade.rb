class ChangeGroupShoppingListsCascade < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :group_shopping_lists, :shopping_lists
    add_foreign_key :group_shopping_lists, :shopping_lists, null: false, type: :uuid, on_delete: :cascade
    remove_foreign_key :group_shopping_lists, :groups
    add_foreign_key :group_shopping_lists, :groups, null: false, type: :uuid, on_delete: :cascade
  end
end
