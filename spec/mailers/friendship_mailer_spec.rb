require "rails_helper"

RSpec.describe FriendshipMailer, type: :mailer do

  describe "invitation_email" do
    let(:sender) { create(:user) }

    let(:invitation) { FriendshipInvitation.new(email: "odbiorca@example.com") }

    let!(:mail) { FriendshipMailer.invitation_email(inviter: sender, invitee_email: invitation.email) }

    it "is successfully instantiated" do
      expect(mail).to be_a(ActionMailer::MessageDelivery)
    end

    it "renders the body without crashing" do
      expect(mail.body).to be_present
    end

    it "receives the correct recipient" do
      expect(mail.to).to include(invitation.email)
    end

    it "renders the sender's email in the body" do
      expect(mail.body).to include(sender.email)
    end

    it "renders link to friends page" do
      expect(mail.body).to include(friends_url)
    end

  end


end
