class FriendshipsController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_policy_scoped, only: [ :create, :confirm, :destroy, :destroy_by_friend, :new ]
  skip_after_action :verify_authorized, only: [ :destroy_by_friend, :new ]

  def new
    @friendship_invitation = FriendshipInvitation.new
  end

  def create
    @friendship_invitation = FriendshipInvitation.new(friendship_invitation_params)
    authorize :friendship, :create?

    if @friendship_invitation.valid?

      result = InviteFriendService.new(user: current_user, invitee_email: @friendship_invitation.email).call
      if result.success
        case result.status
        in InviteFriendService::Status::FRIENDSHIP_REQUESTED
          flash[:notice] = I18n.t("friendships.create.requested")
        in InviteFriendService::Status::FRIENDSHIP_ACCEPTED
          flash[:notice] = I18n.t("friendships.create.success")
        in InviteFriendService::Status::EMAIL_INVITATION_SENT
          flash[:notice] = I18n.t("friendships.create.email_invitation_sent")
        in InviteFriendService::Status::FRIENDSHIP_ALREADY_PENDING
          flash[:info] = I18n.t("friendships.create.already_pending")
        in InviteFriendService::Status::FRIENDSHIP_ALREADY_EXISTS
          flash[:info] = I18n.t("friendships.create.already_exists")
        in InviteFriendService::Status::ALREADY_INVITED
          flash[:info] = I18n.t("invitation_links.create.already_invited")
        else
          flash[:alert] = I18n.t("errors.messages.unknown")
        end
      else
        flash[:alert] = result.errors.full_messages.to_sentence
      end

      redirect_to friends_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def confirm
    @friendship = Friendship.find(params[:id])
    authorize @friendship, :confirm?
    if @friendship.accepted!
      flash[:success] = I18n.t("friendships.confirm.success")
    else
      flash[:alert] = I18n.t("friendships.confirm.error")
    end
    redirect_to friends_path
  end

  def destroy_by_friend
    u = current_user
    f = User.find(params[:friend_id])
    @friendship = Friendship.find_by!(user_id: [ u, f ], friend_id: [ f, u ])
    destroy
  end

  def destroy
    @friendship ||= Friendship.find(params[:id])
    authorize @friendship, :destroy?
    is_accepted = @friendship.accepted?
    is_pending = @friendship.pending?
    is_rejected = @friendship.rejected?
    if @friendship.destroy
      if is_pending
        flash[:warning] = I18n.t("friendships.destroy.request.success")
      elsif is_accepted
        flash[:warning] = I18n.t("friendships.destroy.success")
      end
    else
      flash[:alert] = I18n.t("friendships.destroy.error")
    end
    redirect_to friends_path
  end

  private

  def friendship_invitation_params
    params.require(:friendship_invitation).permit(:email)
  end
end
