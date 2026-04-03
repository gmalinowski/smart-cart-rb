class FriendshipsController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_policy_scoped, only: [ :confirm, :destroy, :destroy_by_friend ]
  skip_after_action :verify_authorized, only: [ :destroy_by_friend ]

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
end
