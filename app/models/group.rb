class Group < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :group_shopping_lists
  has_many :shopping_lists, through: :group_shopping_lists
  validates :name, presence: true
  validates :owner_id, presence: true
end
