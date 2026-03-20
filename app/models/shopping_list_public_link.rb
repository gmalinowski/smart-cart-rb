
class ShoppingListPublicLink < ApplicationRecord
  belongs_to :shopping_list
  belongs_to :created_by, class_name: "User"
end
