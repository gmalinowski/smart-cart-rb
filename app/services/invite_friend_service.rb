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
      { success: true, message: :friendship_requested }
    else
      { success: false, errors: friendship.errors.full_messages }
    end
  end

  def create_email_invitation_link(user:, invitee_email:)
    link = user.invitation_links.find_or_initialize_email_invitation(inviter: user, recipient_email: invitee_email)

    case [link.persisted?, link.active?]
    in [true, true]
      link.errors.add(:recipient_email, :taken)
      return { success: false, errors: link.errors.full_messages }
    in [true, false]
      execute_invitation_process(link, :renew!, user, invitee_email)
    in [false, _]
      execute_invitation_process(link, :save, user, invitee_email)
    end
  end

  def execute_invitation_process(link, method, user, invitee_email)
    if link.send(method)
      InvitationMailer.friend_invitation_to_signup(inviter: user, invitee_email: invitee_email).deliver_later
      { success: true, message: :email_invitation_sent }
    else
      { success: false, errors: link.errors.full_messages }
    end
  end

end