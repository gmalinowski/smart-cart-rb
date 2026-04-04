require 'rails_helper'

RSpec.describe InvitationLinkPolicy, type: :policy do
  subject { described_class.new(user, invitation_link) }
  let(:user) { create(:user) }
  let(:owner) { create(:user) }
  let(:invitation_link) { create(:invitation_link, user: owner) }

  describe 'accept?' do
    context 'when user is present' do
      it { is_expected.to permit_action(:accept) }
    end
    context 'when user is nil' do
      let(:user) { nil }
      it { is_expected.to forbid_action(:accept) }
    end
    context 'when invitation link is expired' do
      let(:invitation_link) { create(:invitation_link, expires_at: 1.day.ago) }
    end
    context 'when invitation link is already used' do
      let(:invitation_link) { create(:invitation_link, max_uses: 1, uses_count: 1) }
    end
  end

  context 'owner' do
    let(:user) { owner }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:create) }
  end

  context 'non owner' do
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:create) }
  end

  context 'guest' do
    let(:user) { nil }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:create) }
  end
end
