
require 'rails_helper'

RSpec.describe InvitationLink, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should validate_presence_of(:user_id) }
  end

  describe 'scopes' do
    describe '.active' do
      let(:user) { create(:user) }
      it "returns invitations that are not expired and have uses left" do
        create(:invitation_link, expires_at: 1.day.ago, user: user)
        create(:invitation_link, max_uses: 1, uses_count: 1, user: user)
        create(:invitation_link, max_uses: 2, uses_count: 0, user: user)
        create(:invitation_link, user: user)
        expect(InvitationLink.active.count).to eq(2)
      end

      it "excludes expired links" do
        create(:invitation_link, expires_at: 10.day.ago, user: user)
        expect(InvitationLink.active.count).to eq(0)
      end
      it "excludes links with max usage reached" do
        create(:invitation_link, max_uses: 1, uses_count: 1, user: user)
        end
    end
    describe "#active?" do
      it "returns true when not expired and has uses left" do
        link = build(:invitation_link, expires_at: 1.day.from_now, max_uses: 5, uses_count: 0)
        expect(link.active?).to be true
      end

      it "returns false when expired" do
        link = build(:invitation_link, expires_at: 1.day.ago)
        expect(link.active?).to be false
      end

      it "returns false when max uses reached" do
        link = build(:invitation_link, max_uses: 1, uses_count: 1)
        expect(link.active?).to be false
      end
    end
  end

  describe 'validations' do
    it "should not allow duplicate tokens" do
      user = create(:user)
      link = create(:invitation_link, user: user)
      expect {
        create(:invitation_link, user: user, token: link.token)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "should allow create many links for one user" do
      user = create(:user)
      create(:invitation_link, user: user)
      expect {
        create(:invitation_link, user: user)
      }.not_to raise_error
      expect(user.invitation_links.count).to eq(2)
    end
  end

  describe 'database defaults' do
    let(:user) { create(:user) }
    subject { create(:invitation_link, user: user) }

    it { expect(subject.expires_at).to be_within(1.minute).of(30.days.from_now) }
    it { expect(subject.token).to be_present }
    it { expect(subject.uses_count).to eq(0) }
    it { expect(subject.max_uses). to eq(1) }
  end

  describe 'dependencies destroy' do
    it 'destroys links when user is destroyed' do
      user = create(:user)
      create(:invitation_link, user: user)
      expect { user.destroy }.to change(InvitationLink, :count).by(-1)
    end
  end
end
