class Friendship < ApplicationRecord
  enum :status, { pending: 0, accepted: 1, rejected: 2 }
  belongs_to :user
  belongs_to :friend, class_name: "User"

  validates :user_id, presence: true
  validates :friend_id, presence: true
  validate :users_must_be_confirmed
  validate :cannot_be_friends_with_self
  validate :friendship_already_exists

  private

  def friendship_already_exists
    return unless user && friend
    if user.friends_with?(friend)
      errors.add(:friend, "is already friend")
    elsif user.pending_friendship_with?(friend)
      errors.add(:friend, "friendship already pending")
    end
  end

  def friendship_must_be_unique
    if UserFriendView.exists?(user_id: user_id, friend_id: friend_id)
      errors.add(:friend, "is already friends")
    end
  end

  def cannot_be_friends_with_self
    errors.add(:friend, "cannot be friends with self") if user == friend
  end

  def users_must_be_confirmed
    errors.add(:friend, "must be confirmed") unless friend&.confirmed?
    errors.add(:user, "must be confirmed") unless user&.confirmed?
  end
end
