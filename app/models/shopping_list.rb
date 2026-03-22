class ShoppingList < ApplicationRecord
  has_many :shopping_list_items, -> { unchecked_first }
  has_many :shopping_list_public_links
  belongs_to :owner, class_name: "User", foreign_key: "owner_id"

  validates :owner_id, presence: true
  validates :name, presence: true

  scope :drafts, -> { all }

  def add_item!(name)
    shopping_list_items.create!(name: name)
  end

  def destroy_item(item)
    shopping_list_items.destroy(item)
  end
end
