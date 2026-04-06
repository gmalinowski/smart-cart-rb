# Preview all emails at http://localhost:3000/rails/mailers/friendship_mailer_mailer
class FriendshipMailerPreview < ActionMailer::Preview

  def invitation_email
    FriendshipMailer.invitation_email(inviter: User.first, invitee_email: "john@example.com")
  end

end
