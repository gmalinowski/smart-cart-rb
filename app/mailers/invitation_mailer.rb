class InvitationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.invitation_mailer.email_invitation_link.subject
  #
  def friend_invitation_to_signup(inviter:, invitee_email:)
    @inviter = inviter
    mail to: invitee_email
  end
end
