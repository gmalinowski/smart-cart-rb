class FriendshipsController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_policy_scoped, only: [ :confirm ]

  def confirm
    @friendship = Friendship.find(params[:id])
    authorize @friendship
    if @friendship.accepted!
      flash[:success] = I18n.t("friendships.confirm.success")
      redirect_to friends_path
    else
      flash[:alert] = I18n.t("friendships.confirm.error")
    end
  end
end
