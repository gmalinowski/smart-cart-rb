
class Friendship < ApplicationRecord
  enum :status, { pending: 0, accepted: 1, rejected: 2 }
  belongs_to :user
  belongs_to :friend, class_name: "User"

  validates :user_id, presence: true
  validates :friend_id, presence: true
  validate :cannot_be_friends_with_self
  validate :users_must_be_confirmed

  private
  def cannot_be_friends_with_self
    errors.add(:friend, "cannot be friends with self") if user == friend
  end

  def users_must_be_confirmed
    errors.add(:friend, "must be confirmed") unless friend&.confirmed?
    errors.add(:user, "must be confirmed") unless user&.confirmed?
  end
end
