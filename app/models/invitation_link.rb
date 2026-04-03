
class InvitationLink < ApplicationRecord
  enum :invitation_type, { link_invitation: 0, email_invitation: 1 }
  store_accessor :metadata, :recipient_email
  belongs_to :user

  validates :user_id, presence: true
  validates :recipient_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :email_invitation?

  scope :active, -> { where("expires_at > ?", Time.current).where("max_uses > uses_count") }

  def active?
    Time.current < expires_at && max_uses > uses_count
  end
end
