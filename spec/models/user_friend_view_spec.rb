require 'rails_helper'

RSpec.describe UserFriendView, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:friend) }
  end

  describe 'view returns bidirectional friendships' do
    let(:user_1) { create(:user) }
    let(:user_2) { create(:user) }
    let(:user_3) { create(:user) }
    let(:user_4) { create(:user) }

    before do
      create(:friendship, user: user_1, friend: user_2, status: :accepted)
      create(:friendship, user: user_1, friend: user_3, status: :pending)
      create(:friendship, user: user_2, friend: user_3, status: :accepted)
    end

    it 'returns friendship for user_1' do
      expect(UserFriendView.where(user: user_1).pluck(:friend_id)).to include(user_2.id)
    end

    it 'returns friendship for user_2' do
      expect(UserFriendView.where(user: user_2).pluck(:friend_id)).to include(user_1.id)
    end

    it 'does not return friendship for user_4 because has no friendships' do
      expect(UserFriendView.where(user: user_4).pluck(:friend_id).count).to eq(0)
    end

    it 'user_1 are not friends with user_3 because status is pending' do
      expect(UserFriendView.where(user: user_1).pluck(:friend_id)).to_not include(user_3.id)
    end

    it 'user_2 are friends with user_1 and user_3' do
      expect(UserFriendView.where(user: user_2).pluck(:friend_id)).to include(user_1.id, user_3.id)
    end
  end
end
