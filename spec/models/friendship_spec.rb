require 'rails_helper'

RSpec.describe Friendship, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:friend) }
  end

  describe 'validations' do
    it 'user_id and friend_id must be present' do
      user = create(:user)
      friend = create(:user)
      expect(build(:friendship, user: user, friend: friend)).to be_valid
      expect(build(:friendship, user: user)).to_not be_valid
      expect(build(:friendship, friend: friend)).to_not be_valid
    end
    it 'users must be confirmed' do
      user = create(:user, confirmed_at: nil)
      friend = create(:user, confirmed_at: Time.zone.now)
      expect(build(:friendship, user: user, friend: friend)).to_not be_valid
    end
    it "shouldn't allow a user to be friends with themselves" do
      user = create(:user)
      expect {
        create(:friendship, user: user, friend: user)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "shouldn't allow a user to be friends with unsaved user" do
      user = create(:user)
      expect {
        create(:friendship, user: user, friend: build(:user))
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "shouldn't allow duplicate friendships" do
      user = create(:user)
      friend = create(:user)
      create(:friendship, user: user, friend: friend)
      expect {
        create(:friendship, user: user, friend: friend)
      }.to raise_error(ActiveRecord::RecordNotUnique)
      expect {
        create(:friendship, user: friend, friend: user)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'dependencies' do
    let(:user) { create(:user) }
    let(:friend) { create(:user) }

    it 'destroys friendships when user is destroyed' do
      create(:friendship, user: user, friend: friend)
      expect { user.destroy }.to change(Friendship, :count).by(-1)
    end

    it 'destroys friendships when friend is destroyed' do
      create(:friendship, user: user, friend: friend)
      expect { friend.destroy }.to change(Friendship, :count).by(-1)
    end
  end
end
