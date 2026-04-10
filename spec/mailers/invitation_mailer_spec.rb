require "rails_helper"

RSpec.describe InvitationMailer, type: :mailer do
  describe "email_invitation_link" do
    let(:inviter) { create(:user) }
    let(:inviter_email_safe) { CGI.escapeHTML(inviter.email) }
    let(:invitee_email) { "test@example.com" }
    let(:invitee_email_safe) { CGI.escapeHTML(invitee_email) }
    let(:mail) { InvitationMailer.friend_invitation_to_signup(inviter: inviter, invitee_email: invitee_email) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("invitation_mailer.friend_invitation_to_signup.subject", sender: inviter.email))
      expect(mail.to).to eq([ invitee_email ])
    end

    it "renders the body" do
      expected_text = I18n.t("invitation_mailer.friend_invitation_to_signup.body", sender: inviter_email_safe)
      expect(mail.body.encoded).to include(expected_text)
    end

    it "includes sender's email in the body" do
      expect(mail.body.encoded).to include(inviter_email_safe)
    end

    it 'includes link to sign up page' do
      expect(mail.body.encoded).to include(new_user_registration_url)
    end
  end
end
