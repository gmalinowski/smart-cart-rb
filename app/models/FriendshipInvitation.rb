
class FriendshipInvitation
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end