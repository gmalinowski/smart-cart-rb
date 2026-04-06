class FriendshipMailer < ApplicationMailer

  def invitation_email
    @invitation = params[:invitation]
    @sender = params[:sender]
    mail(to: @invitation.email)
  end

  def invitation_to_system_email

  end

end
