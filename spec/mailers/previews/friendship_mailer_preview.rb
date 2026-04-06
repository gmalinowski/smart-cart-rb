# Preview all emails at http://localhost:3000/rails/mailers/friendship_mailer_mailer
class FriendshipMailerPreview < ActionMailer::Preview

  def invitation_email
    FriendshipMailer.with(invitation: FriendshipInvitation.new(email: "joe@example.com"), sender: User.first).invitation_email
  end

end
