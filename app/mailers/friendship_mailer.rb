class FriendshipMailer < ApplicationMailer
  def invitation_email(inviter:, invitee_email:)
    @inviter = inviter
    mail(to: invitee_email)
  end

  def invitation_to_system_email
  end
end
