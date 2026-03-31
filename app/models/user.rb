class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable
  before_save :update_session_version, if: :will_save_change_to_encrypted_password?

  has_many :shopping_lists, foreign_key: "owner_id"
  has_many :groups, foreign_key: "owner_id"

  has_many :invitation_links

  has_many :user_friend_views, foreign_key: :user_id, class_name: "UserFriendView"
  has_many :friends, through: :user_friend_views, source: :friend

  has_many :friendships, foreign_key: :user_id
  has_many :received_friendships, foreign_key: :friend_id, class_name: "Friendship"
  has_many :pending_friendships, -> { where(status: :pending) }, foreign_key: :user_id, class_name: "Friendship"
  has_many :pending_received_friendships, -> { where(status: :pending) }, foreign_key: :friend_id, class_name: "Friendship"

  def friends_with?(other_user)
    return false if other_user.nil?
    friends.exists?(id: other_user.id)
  end

  def pending_friendship_with?(other_user)
    return false if other_user.nil?
    pending_friendships.exists?(friend_id: other_user.id) ||
      pending_received_friendships.exists?(user_id: other_user.id)
  end

  private
  def update_session_version
    self.session_version += 1
  end
end
