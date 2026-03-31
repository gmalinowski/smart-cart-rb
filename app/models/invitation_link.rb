
class InvitationLink < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true

  scope :active, -> { where("expires_at > ?", Time.current).where("max_uses > uses_count") }

  def active?
    Time.current < expires_at && max_uses > uses_count
  end
end
