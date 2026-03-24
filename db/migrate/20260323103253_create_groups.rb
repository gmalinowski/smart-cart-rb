class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups, id: :uuid do |t|
      t.string :name
      t.belongs_to :owner, foreign_key: { to_table: :users }, null: false, type: :uuid

      t.timestamps
    end
  end
end
