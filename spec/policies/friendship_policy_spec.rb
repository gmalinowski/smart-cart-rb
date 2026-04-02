require 'rails_helper'

RSpec.describe FriendshipPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }
  let(:stranger) { create(:user) }

  describe 'confirm?' do
    context 'invitee can confirm pending friendship' do
      let(:friendship) { create(:friendship, user: friend, friend: user, status: :pending) }
      subject { described_class.new(user, friendship) }
      it { is_expected.to permit_action(:confirm) }
    end

    context 'inviter cannot confirm pending friendship' do
      let(:friendship) { create(:friendship, user: user, friend: friend, status: :pending) }
      subject { described_class.new(user, friendship) }
      it { is_expected.to forbid_action(:confirm) }
    end

    context 'cannot confirm rejected friendship' do
      let(:friendship) { create(:friendship, user: friend, friend: user, status: :rejected) }
      subject { described_class.new(user, friendship) }
      it { is_expected.to forbid_action(:confirm) }
    end

    context 'cannot confirm already accepted friendship' do
      let(:friendship) { create(:friendship, user: friend, friend: user, status: :accepted) }
      subject { described_class.new(user, friendship) }
      it { is_expected.to forbid_action(:confirm) }
    end

    context 'stranger cannot confirm pending friendship' do
      let(:friendship) { create(:friendship, user: user, friend: friend, status: :pending) }
      subject { described_class.new(stranger, friendship) }
      it { is_expected.to forbid_action(:confirm) }
    end
  end
end
