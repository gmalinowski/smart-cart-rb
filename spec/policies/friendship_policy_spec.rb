require 'rails_helper'

RSpec.shared_examples "allow friendship destruction" do |status|
  describe 'user is the inviter' do
    context "when status is #{status}" do
      let(:friendship) { create(:friendship, status, user: user, friend: friend) }
      subject { described_class.new(user, friendship) }
      it { is_expected.to permit_action(:destroy) }
    end
  end

  describe 'user is the invitee' do
    context "when status is #{status}" do
      let(:friendship) { create(:friendship, status, user: friend, friend: user) }
      subject { described_class.new(user, friendship) }
      it { is_expected.to permit_action(:destroy) }
    end
  end
end

RSpec.describe FriendshipPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }
  let(:stranger) { create(:user) }

  describe 'destroy?' do
    Friendship.statuses.keys.each do |status|
      it_behaves_like "allow friendship destruction", status
    end

    context 'when user is the stranger' do
      let(:friendship) { create(:friendship, user: friend, friend: user) }
      subject { described_class.new(stranger, friendship) }
      it { is_expected.to forbid_action(:destroy) }
    end

    context 'when there is no user' do
      let(:friendship) { create(:friendship, user: friend, friend: user) }
      subject { described_class.new(nil, friendship) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

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

  describe 'auto_confirm?' do
    context 'when invitee started accepting request' do
      let(:friendship) { create(:friendship, user: user, friend: friend, status: :pending) }
      subject { described_class.new(user, friendship) }
      it { is_expected.to permit_action(:auto_confirm) }
    end
    context 'when inviter started accepting request' do
      let(:friendship) { create(:friendship, user: friend, friend: user, status: :pending) }
      subject { described_class.new(user, friendship) }
      it { is_expected.to forbid_action(:auto_confirm) }
    end
    context 'when request is already accepted' do
      let(:friendship) { create(:friendship, user: friend, friend: user, status: :accepted) }
      subject { described_class.new(user, friendship) }
      it { is_expected.to forbid_action(:auto_confirm) }
    end
    context 'when request does not exist' do
      let(:friendship) { nil }
      subject { described_class.new(user, friendship) }
      it { is_expected.to forbid_action(:auto_confirm) }
    end
    context 'when stranger accepting request' do
      let(:friendship) { create(:friendship, user: user, friend: friend, status: :pending) }
      subject { described_class.new(stranger, friendship) }
      it { is_expected.to forbid_action(:auto_confirm) }
    end
  end

  describe 'create?' do
    context 'when user is not logged in' do
      let(:friendship) { create(:friendship, user: friend, friend: user) }
      subject { described_class.new(nil, friendship) }
      it { is_expected.to forbid_action(:create) }
    end
    context 'when user is logged in' do
      let(:friendship) { create(:friendship, user: friend, friend: user) }
      subject { described_class.new(user, friendship) }
      it { is_expected.to permit_action(:create) }
    end
  end
end
