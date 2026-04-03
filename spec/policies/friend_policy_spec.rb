require 'rails_helper'

RSpec.describe FriendPolicy, type: :policy do

  describe 'show?' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:friendship) { create(:friendship, user: user, friend: other_user, status: :accepted) }
    subject { described_class.new(user, user) }
    context 'when user is present' do
      subject { described_class.new(user, :friend) }
      it { is_expected.to permit_action(:show) }
    end

    context 'when user is nil' do
      subject { described_class.new(nil, other_user) }
      it { is_expected.to forbid_action(:show) }
    end
  end
end