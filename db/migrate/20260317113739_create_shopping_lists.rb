class CreateShoppingLists < ActiveRecord::Migration[8.1]
  def change
    create_table :shopping_lists, id: :uuid do |t|
      t.belongs_to :owner, foreign_key: { to_table: :users }, null: false, type: :uuid
      t.string :name, null: false
      t.text :note, null: true
      t.timestamps
    end
  end
end
