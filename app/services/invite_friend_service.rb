class InviteFriendService
  module Status
    FRIENDSHIP_ACCEPTED = :friendship_accepted
    FRIENDSHIP_REQUESTED = :friendship_requested
    EMAIL_INVITATION_SENT = :email_invitation_sent
    ALREADY_INVITED = :already_invited
    FRIENDSHIP_ALREADY_PENDING = :friendship_already_pending
    FRIENDSHIP_ALREADY_EXISTS = :friendship_already_exists
  end

  Result = Data.define(:success, :status, :errors)

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
      if @user.pending_received_friends.exists?(id: invitee.id)
        accept_friendship(user: @user, friend: invitee)
      elsif @user.friends.exists?(id: invitee.id)
        Result.new(success: true, status: Status::FRIENDSHIP_ALREADY_EXISTS, errors: nil)
      elsif @user.pending_sent_friends.exists?(id: invitee.id)
        Result.new(success: true, status: Status::FRIENDSHIP_ALREADY_PENDING, errors: nil)
      else
        create_friendship(user: @user, friend: invitee)
      end
    else
      create_email_invitation_link(user: @user, invitee_email: @invitee_email)
    end
  end

  private

  def accept_friendship(user:, friend:)
    friendship = user.received_friendships.find_by(user_id: friend.id)
    if friendship&.update(status: :accepted)
      Result.new(success: true, status: Status::FRIENDSHIP_ACCEPTED, errors: nil)
    else
      errors = if friendship
                 friendship.errors
      else
                 f = Friendship.new
                 f.errors.add(:base, I18n.t("errors.messages.unknown"))
                 f.errors
      end
      Result.new(success: false, status: nil, errors: errors)
    end
  end

  def create_friendship(user:, friend:)
    friendship = Friendship.new(user: user, friend: friend, status: :pending)
    if friendship.save
      FriendshipMailer.invitation_email(inviter: user, invitee_email: friend.email).deliver_later
      Result.new(success: true, status: Status::FRIENDSHIP_REQUESTED, errors: nil)
    else
      if friendship.errors.added?(:friend_id, :taken)
        Result.new(success: true, status: Status::FRIENDSHIP_ALREADY_EXISTS, errors: nil)
      elsif friendship.errors.added?(:friend_id, :pending)
        Result.new(success: true, status: Status::FRIENDSHIP_ALREADY_PENDING, errors: nil)
      else
        Result.new(success: false, status: nil, errors: friendship.errors)
      end
    end
  end

  def create_email_invitation_link(user:, invitee_email:)
    link = user.invitation_links.find_or_initialize_email_invitation(inviter: user, recipient_email: invitee_email)

    case [ link.persisted?, link.active? ]
    in [ true, true ]
      Result.new(success: true, status: Status::ALREADY_INVITED, errors: nil)
    in [ true, false ]
      execute_invitation_process(link, :renew!, user, invitee_email)
    in [ false, _ ]
      execute_invitation_process(link, :save, user, invitee_email)
    end
  end

  def execute_invitation_process(link, method, user, invitee_email)
    if link.send(method)
      InvitationMailer.friend_invitation_to_signup(inviter: user, invitee_email: invitee_email).deliver_later
      Result.new(success: true, status: Status::EMAIL_INVITATION_SENT, errors: nil)
    else
      Result.new(success: false, status: nil, errors: link.errors)
    end
  end
end
