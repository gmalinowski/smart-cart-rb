class AddVisitedAtToListVisits < ActiveRecord::Migration[8.1]
  def change
    add_column :list_visits, :visited_at, :datetime, null: false
  end
end
