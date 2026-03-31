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

  describe 'helpers' do
    describe 'friends_with?' do
      it 'returns true if user is friends with friend' do
        user = create(:user)
        friend = create(:user)
        create(:friendship, user: user, friend: friend, status: :accepted)
        expect(user.friends_with?(friend)).to be_truthy
      end
      it 'returns false if user is not friends with friend' do
        user = create(:user)
        friend = create(:user)
        expect(user.friends_with?(friend)).to be_falsey
      end
      it 'returns false if friend is nil' do
        user = create(:user)
        expect(user.friends_with?(nil)).to be_falsey
      end
      it 'returns false if user is nil' do
        friend = create(:user)
        expect(User.new.friends_with?(friend)).to be_falsey
      end
      it 'returns false if friendship is not accepted' do
        user = create(:user)
        friend = create(:user)
        create(:friendship, user: user, friend: friend)
        expect(user.friends_with?(friend)).to be_falsey
      end
    end

    describe 'pending_friends_with?' do
      it 'returns true if user is pending friend with friend' do
          user = create(:user)
          friend = create(:user)
          create(:friendship, user: user, friend: friend, status: :pending)
          expect(user.pending_friendship_with?(friend)).to be_truthy
      end
      it 'returns false if user is not friend with friend' do
          user = create(:user)
          friend = create(:user)
          expect(user.pending_friendship_with?(friend)).to be_falsey
      end
      it 'returns false if friend is nil' do
        user = create(:user)
        expect(user.pending_friendship_with?(nil)).to be_falsey
      end
      it 'returns false if user is nil' do
        friend = create(:user)
        expect(User.new.pending_friendship_with?(friend)).to be_falsey
      end
      it 'returns false if users are accepted friends' do
        user = create(:user)
        friend = create(:user)
        create(:friendship, user: user, friend: friend, status: :accepted)
        expect(user.pending_friendship_with?(friend)).to be_falsey
      end
    end
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
