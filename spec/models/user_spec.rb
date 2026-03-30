require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'session_version' do
    it 'should be incremented when password is changed' do
      user = create(:user)
      expect {
        user.update(password: 'P@assword12', password_confirmation: 'P@assword12')
      }.to change { user.session_version }.by(1)
    end

    it 'does not increment when other attributes change' do
      user = create(:user)
      expect {
        user.update(email: '1234@ggg.com')
      }.not_to change { user.session_version }
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
  end

  describe 'dependencies' do
    it 'destroys associated shopping_lists when destroyed'
  end

  describe 'associations' do
    it { should have_many(:shopping_lists).with_foreign_key('owner_id') }
    it { should have_many(:groups).with_foreign_key('owner_id') }

    it { should have_many(:friendships) }
    it { should have_many(:friends).through(:user_friend_views) }
    it { should have_many(:pending_friendships).with_foreign_key('user_id').class_name('Friendship').conditions(status: :pending) }
    it { should have_many(:pending_received_friendships).with_foreign_key('friend_id').class_name('Friendship').conditions(status: :pending) }

    it { should have_many(:invitation_links) }
  end
end
