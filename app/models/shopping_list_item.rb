class ShoppingListItem < ApplicationRecord
  belongs_to :shopping_list
  validates :name, presence: true

  after_create_commit { broadcast_prepend_to shopping_list }
  after_destroy_commit { broadcast_remove_to shopping_list }
  after_update_commit { broadcast_replace_to shopping_list }

  scope :unchecked_first, -> { order(checked: :asc) }
end
