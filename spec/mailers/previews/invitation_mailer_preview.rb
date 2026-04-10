# Preview all emails at http://localhost:3000/rails/mailers/invitation_mailer_mailer
class InvitationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/invitation_mailer_mailer/email_invitation_link
  def friend_invitation_to_signup
    InvitationMailer.friend_invitation_to_signup(inviter: User.first, invitee_email: "test@test.com")
  end
end
