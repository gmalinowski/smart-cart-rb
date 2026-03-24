class GroupShoppingList < ApplicationRecord
  belongs_to :group
  belongs_to :shopping_list

  validates :group_id, presence: true
  validates :shopping_list_id, presence: true
  validates :shopping_list_id, uniqueness: { scope: :group_id }
end
