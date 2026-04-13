class UserFriendView < ApplicationRecord
  self.table_name = "user_friends_view"
  self.primary_key = :friendship_id
  def readonly? = true

  belongs_to :user
  belongs_to :friend, class_name: "User"
  belongs_to :friendship

  scope :accepted, -> { joins(:friendship).where(friendships: { status: :accepted }) }
  scope :pending, -> { joins(:friendship).where(friendships: { status: :pending }) }
end
