require 'rails_helper'

RSpec.describe UserFriendView, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:friend).class_name('User') }
    it { should belong_to(:friendship) }
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

    it 'returns all links (including pending) for user_1 via raw view' do
      expect(UserFriendView.where(user: user_1).pluck(:friend_id)).to contain_exactly(user_2.id, user_3.id)
    end

    it 'returns only accepted friendship for user_1 using scope' do
      expect(UserFriendView.accepted.where(user: user_1).pluck(:friend_id)).to include(user_2.id)
      expect(UserFriendView.accepted.where(user: user_1).pluck(:friend_id)).not_to include(user_3.id)
    end

    it 'returns bidirectional friendship for user_2 even if they were the "recipient"' do
      expect(UserFriendView.accepted.where(user: user_2).pluck(:friend_id)).to include(user_1.id)
    end

    it 'correctly identifies pending friendships for user_1' do
      expect(UserFriendView.pending.where(user: user_1).pluck(:friend_id)).to contain_exactly(user_3.id)
    end

    it 'user_2 is friends with user_1 and user_3 (both accepted)' do
      expect(UserFriendView.accepted.where(user: user_2).pluck(:friend_id)).to contain_exactly(user_1.id, user_3.id)
    end

    it 'does not return anything for user_4' do
      expect(UserFriendView.where(user: user_4).count).to eq(0)
    end
  end
end
