class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable
  before_save :update_session_version, if: :will_save_change_to_encrypted_password?
  after_create_commit :try_to_claim_pending_friendships

  has_many :shopping_lists, foreign_key: "owner_id"
  has_many :groups, foreign_key: "owner_id"

  has_many :list_visits, dependent: :destroy
  has_many :visited_shopping_lists, through: :list_visits, source: :shopping_list
  has_one :last_list_visit, -> { order(visited_at: :desc) }, class_name: "ListVisit"
  has_one :last_visited_shopping_list, through: :last_list_visit, source: :shopping_list

  has_many :invitation_links

  # START read-only
  has_many :user_friend_views, foreign_key: :user_id
  has_many :friends, -> { merge(UserFriendView.accepted) }, through: :user_friend_views, source: :friend
  has_many :pending_friends, -> { merge(UserFriendView.pending) }, through: :user_friend_views, source: :friend
  has_many :pending_sent_friends, -> { merge(UserFriendView.pending.where(is_sender: true)) }, through: :user_friend_views, source: :friend
  has_many :pending_received_friends, -> { merge(UserFriendView.pending.where(is_sender: false)) }, through: :user_friend_views, source: :friend
  # END read-only

  has_many :sent_friendships, foreign_key: :user_id, dependent: :destroy, class_name: "Friendship"
  has_many :received_friendships, foreign_key: :friend_id, dependent: :destroy, class_name: "Friendship"
  has_many :pending_sent_friendships, -> { where(status: :pending) }, foreign_key: :user_id, class_name: "Friendship", dependent: :destroy
  has_many :pending_received_friendships, -> { where(status: :pending) }, foreign_key: :friend_id, class_name: "Friendship", dependent: :destroy

  def after_confirmation
    claim_pending_friendships
  end

  def friends_with?(other_user)
    return false if other_user.nil?
    friends.exists?(id: other_user.id)
  end

  def pending_friendship_with?(other_user)
    return false if other_user.nil?
    pending_friends.exists?(id: other_user.id)
  end

  private

  def update_session_version
    self.session_version += 1
  end

  def try_to_claim_pending_friendships
    if confirmed?
      claim_pending_friendships
    end
  end

  def claim_pending_friendships
    ActiveRecord::Base.transaction do
      InvitationLink.active_for_recipient(self).each do |invitation|
        Friendship.create(user: invitation.user, friend: self, status: :pending)
        invitation.increment!(:uses_count)
      end
    end
  end
end
