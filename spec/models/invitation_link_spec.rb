
require 'rails_helper'

RSpec.describe InvitationLink, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should validate_presence_of(:user_id) }
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
