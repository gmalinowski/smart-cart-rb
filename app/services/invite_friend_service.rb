
class InviteFriendService
  def initialize(user:, invitee_email:)
    @user = user
    @invitee_email = invitee_email&.downcase&.strip
    if @user.nil?
      raise ArgumentError, "User not found"
    elsif @invitee_email.nil?
      raise ArgumentError, "Invitee email not found"
    end
  end

  def call
    invitee = User.find_by(email: @invitee_email)
    if invitee
      create_friendship(user: @user, friend: invitee)
    else
      create_email_invitation_link(user: @user, invitee_email: @invitee_email)
    end
  end

  private

  def create_friendship(user:, friend:)
    friendship = Friendship.new(user: user, friend: friend, status: :pending)
    if friendship.save
      FriendshipMailer.invitation_email(inviter: user, invitee_email: friend.email).deliver_later
      { success: true, message: :success }
    else
      { success: false, errors: friendship.errors.full_messages }
    end
  end
  def create_email_invitation_link(user:, invitee_email:)
    invitation_link = InvitationLink.new(user: user, recipient_email: invitee_email)
    if invitation_link.save
      # FriendshipMailer.invitation_email(inviter: user, invitee_email: invitee_email).deliver_later
      { success: true, message: :email_invitation_created }
    else
      { success: false, errors: invitation_link.errors.full_messages }
    end
  end
end