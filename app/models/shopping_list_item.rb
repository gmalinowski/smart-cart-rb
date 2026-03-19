class ShoppingListItem < ApplicationRecord
  belongs_to :shopping_list
  validates :name, presence: true

  after_create_commit { broadcast_prepend_to shopping_list }
  after_destroy_commit { broadcast_remove_to shopping_list }
end
