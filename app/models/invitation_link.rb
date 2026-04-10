class InvitationLink < ApplicationRecord
  enum :invitation_type, { link_invitation: 0, email_invitation: 1 }
  store_accessor :metadata, :recipient_email
  belongs_to :user

  validates :user_id, presence: true

  validate :user_must_be_confirmed, on: :create

  with_options if: :email_invitation? do |email_invitation|
    if :email_invitation?
      email_invitation.validates :recipient_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
      email_invitation.validates :max_uses, inclusion: { in: [ 1 ] }
      email_invitation.validate :recipient_must_not_be_confirmed
    end
  end

  before_validation :normalize_email, if: :email_invitation?

  scope :active, -> { where("expires_at > ?", Time.current).where("max_uses > uses_count") }

  scope :active_for_recipient, ->(recipient) { for_recipient(recipient).active }
  scope :active_for_recipient_email, ->(email) { for_recipient_email(email).active }
  scope :for_recipient, ->(recipient) do
    self.for_recipient_email(recipient.email)
  end

  scope :for_recipient_email, ->(email) do
    where("LOWER(metadata->>'recipient_email') = ?", email.downcase)
      .where(invitation_type: :email_invitation)
  end

  def active?
    return false if expires_at.nil? || max_uses.nil?
    Time.current < expires_at && max_uses > uses_count
  end

  def renew!
    unless email_invitation?
      raise "Cannot renew a link that is not an email invitation"
    end
    update!(expires_at: 30.day.from_now, token: SecureRandom.uuid)
  end

  def self.find_or_initialize_email_invitation(inviter:, recipient_email:)
    inviter.invitation_links.for_recipient_email(recipient_email).first ||
      inviter.invitation_links.build(
        recipient_email: recipient_email,
        invitation_type: :email_invitation
      )
  end

  private

  def user_must_be_confirmed
    return if user&.confirmed?
    errors.add(:user, :not_confirmed)
  end

  def recipient_must_not_be_confirmed
    return if recipient_email.blank?
    errors.add(:recipient_email, :already_registered) if User.find_by(email: recipient_email)&.confirmed?
  end

  def normalize_email
    return if recipient_email.blank?
    self.recipient_email = recipient_email.downcase.strip
  end
end
