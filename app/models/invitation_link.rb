class InvitationLink < ApplicationRecord
  enum :invitation_type, { link_invitation: 0, email_invitation: 1 }
  store_accessor :metadata, :recipient_email
  belongs_to :user

  validates :user_id, presence: true
  validates :recipient_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :email_invitation?
  validates :max_uses, inclusion: { in: [1] }, if: :email_invitation?

  before_validation :normalize_email, if: :email_invitation?

  scope :active, -> { where("expires_at > ?", Time.current).where("max_uses > uses_count") }

  scope :for_recipient, ->(recipient) do
    where("LOWER(metadata->>'recipient_email') = ?", recipient.email.downcase)
      .where(invitation_type: :email_invitation)
  end

  scope :active_for_recipient, ->(recipient) { for_recipient(recipient).active }

  def active?
    Time.current < expires_at && max_uses > uses_count
  end

  private

  def normalize_email
    return if recipient_email.blank?
    self.recipient_email = recipient_email.downcase.strip
  end
end
