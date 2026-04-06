require 'rails_helper'

RSpec.describe FriendshipInvitation, type: :model do
  describe 'email normalization' do
    it 'downcases the email before validation' do
      invitation = FriendshipInvitation.new(email: " ZAPROSZENIE@EXAMPLE.COM  ")
      invitation.valid?

      expect(invitation.email).to eq("zaproszenie@example.com")
    end
  end

  describe 'validations' do
    it 'is invalid with a malformed email' do
      invitation = FriendshipInvitation.new(email: "not-an-email")
      expect(invitation).not_to be_valid
    end
  end
end
