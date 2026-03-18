class ShoppingList < ApplicationRecord
  has_many :shopping_list_items
  belongs_to :owner, class_name: "User", foreign_key: "owner_id"

  validates :owner_id, presence: true
  validates :name, presence: true

  scope :drafts, -> { all }
end
