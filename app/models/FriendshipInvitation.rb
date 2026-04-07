
class FriendshipInvitation
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  before_validation :downcase_email

  attribute :email, :string
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def invitee_exists?
    User&.exists?(email: email&.downcase&.strip)
  end

  private

  def downcase_email
    self.email = email&.downcase&.strip
  end
end
