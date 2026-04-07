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

  describe 'helpers' do
    describe 'invitee_exists?' do
      it 'returns true if the invitee exists' do
        user = create(:user)
        invitation = FriendshipInvitation.new(email: user.email)
        expect(invitation.invitee_exists?).to be true
      end

      it 'ignores case when checking for existing invitee' do
        user = create(:user, email: "one@wp.pl")
        invitation = FriendshipInvitation.new(email: "  ONe@wp.PL   ")
        expect(invitation.invitee_exists?).to be true
      end

      it 'returns false if the invitee does not exist' do
        invitation = FriendshipInvitation.new(email: 'nonexistent@example.com')
        expect(invitation.invitee_exists?).to be false
      end

      it 'returns false if the invitee is nil' do
        invitation = FriendshipInvitation.new(email: nil)
        expect(invitation.invitee_exists?).to be false
      end
    end
  end
end
