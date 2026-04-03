require 'rails_helper'

RSpec.describe InvitationLink, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should validate_presence_of(:user_id) }
  end

  describe 'enums' do
    it "defines the expected invitation types" do
      expected_invitation_types = {
        "link_invitation" => 0,
        "email_invitation" => 1
      }
      expect(InvitationLink.invitation_types).to eq(expected_invitation_types)
    end

    it "responds to type predicates" do
      link = create(:invitation_link, invitation_type: :link_invitation, user: create(:user))
      expect(link.link_invitation?).to be true
      expect(link.email_invitation?).to be false
    end
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
        expect(InvitationLink.active.count).to eq(0)
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

    it "does not allow duplicate email_links from the same user to the same email" do
      user = create(:user)
      create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: "jan@example.com")
      expect {
        create(:invitation_link, user: user, invitation_type: :email_invitation, recipient_email: "jan@example.com")
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'recipient_email (metadata accessor)' do
    let(:invitation) { create(:invitation_link, invitation_type: :link_invitation, user: create(:user)) }
    it "allows read/write access to recipient_email" do
      expect(invitation.recipient_email).to be_nil
      invitation.recipient_email = "new_email@example.com"
      expect(invitation.recipient_email).to eq("new_email@example.com")
    end

    describe 'validations' do
      let(:invitation) { create(:invitation_link, invitation_type: :email_invitation, recipient_email: "jan@example.com", user: create(:user)) }
      context 'when invitation type is email_invitation' do
        it 'is invalid without recipient_email' do
          invitation.recipient_email = nil
          expect(invitation).to be_invalid
          expect(invitation.errors[:recipient_email]).to include(
                                                           invitation.errors.generate_message(:recipient_email, :blank)
                                                         )
        end
        it "is invalid with an incorrect email format" do
          invitation.recipient_email = "invalid_email"
          expect(invitation).to be_invalid
          expect(invitation.errors[:recipient_email]).to include(
                                                           invitation.errors.generate_message(:recipient_email, :invalid)
                                                         )
        end
        it "is valid with a correct email format" do
          invitation.recipient_email = "test@example.com"
          expect(invitation).to be_valid
        end
      end
      context 'when invitation type is link_invitation' do
        it 'is valid without recipient_email' do
          invitation.invitation_type = :link_invitation
          invitation.recipient_email = nil
          expect(invitation).to be_valid
          end
        end
    end
  end

  describe 'database defaults' do
    let(:user) { create(:user) }
    subject { create(:invitation_link, user: user) }

    it { expect(subject.expires_at).to be_within(1.minute).of(30.days.from_now) }
    it { expect(subject.token).to be_present }
    it { expect(subject.uses_count).to eq(0) }
    it { expect(subject.max_uses).to eq(1) }
  end

  describe 'dependencies destroy' do
    it 'destroys links when user is destroyed' do
      user = create(:user)
      create(:invitation_link, user: user)
      expect { user.destroy }.to change(InvitationLink, :count).by(-1)
    end
  end
end
