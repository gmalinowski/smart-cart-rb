class ListVisit < ApplicationRecord
  belongs_to :user
  belongs_to :shopping_list

  validates :user_id, presence: true
  validates :shopping_list_id, presence: true
  validates :visited_at, presence: true
end