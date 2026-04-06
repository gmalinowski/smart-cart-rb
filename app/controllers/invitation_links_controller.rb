class InvitationLinksController < ApplicationController
  before_action :authenticate_user!
  before_action :find_active_invitation_link, only: [ :accept ]
  skip_after_action :verify_policy_scoped, only: [ :create, :destroy, :accept ]

  def create
    @invitation_link = InvitationLink.new(user: current_user)
    authorize @invitation_link
    unless @invitation_link.save
      flash[:alert] = I18n.t("invitation_links.create.error")
      redirect_back(fallback_location: root_path, status: :unprocessable_content)
    end
    respond_to do |format|
      format.turbo_stream { render :invitation_link_modal }
    end
  end

  def destroy
    @invitation_link = InvitationLink.find(params[:id])
    authorize @invitation_link
    if @invitation_link.destroy
      flash[:notice] = "Invitation link deleted"
    else
      flash[:alert] = "Invitation link could not be deleted"
    end
  end

  def accept
    @inviter = @invitation_link.user
    @invitee = current_user

    received_request = current_user.pending_friendships.find_by(friend: @inviter)
    if received_request
      authorize received_request, :auto_confirm?
      if received_request.accepted!
        @invitation_link.increment!(:uses_count)
        flash[:success] = I18n.t("friendships.confirm.success")
        redirect_to friends_path and return
      end
    else
      @friendship = Friendship.new(user: @inviter, friend: @invitee, status: :pending)
      if @friendship.invalid?
        flash[:warning] = @friendship.errors.full_messages.to_sentence
        redirect_to root_path
      elsif @friendship.save
        @invitation_link.increment!(:uses_count)
      end
    end
  end

  private

  def find_active_invitation_link
    @invitation_link = InvitationLink.includes(:user).find_by(token: params[:token])

    unless @invitation_link
      flash[:alert] = "Invalid invitation link"
      redirect_to root_path and return
    end

    unless @invitation_link.active?
      flash[:info] = "Invitation link has expired, ask the inviter to send you a new one"
      redirect_to root_path and return
    end

    authorize @invitation_link, :accept?
  end
end
