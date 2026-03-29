class UserFriendView < ApplicationRecord
  self.table_name = "user_friends_view"
  self.primary_key = nil

  belongs_to :user
  belongs_to :friend, class_name: "User"

  def readonly? = true
end
