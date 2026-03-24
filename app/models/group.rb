class Group < ApplicationRecord
  belongs_to :owner, class_name: "User"
  validates :name, presence: true
  validates :owner_id, presence: true
end
