class AddSessionVersionToUser < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :session_version, :integer, default: 1, null: false
  end
end
