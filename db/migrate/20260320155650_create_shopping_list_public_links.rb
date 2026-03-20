class CreateShoppingListPublicLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :shopping_list_public_links, id: :uuid do |t|
      t.belongs_to :shopping_list, foreign_key: { on_delete: :cascade, on_update: :cascade }, null: false, type: :uuid
      t.belongs_to :created_by, foreign_key: { to_table: :users }, null: false, type: :uuid
      t.integer :permission, null: false, default: 0
      t.string :share_token, null: false, default: SecureRandom.uuid, index: { unique: true }
      t.datetime :expires_at,  null: true
      t.timestamps
    end
  end
end
