class InvitationLinksController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_policy_scoped, only: [ :create, :destroy ]

  def create
    @invitation_link = InvitationLink.new(user: current_user)
    authorize @invitation_link
    if @invitation_link.save
      flash.now[:notice] = "Invitation link created"
    else
      flash.now[:alert] = "Invitation link could not be created"
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
end
