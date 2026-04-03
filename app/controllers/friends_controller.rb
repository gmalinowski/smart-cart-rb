  class FriendsController < ApplicationController
    before_action :authenticate_user!
    skip_after_action :verify_policy_scoped, only: [ :show ]

    def show
      authorize :friend, :show?
      @friends = current_user.friends
      @pending_received_friendships = current_user.pending_received_friendships.includes(:friend)
      @pending_friendships = current_user.pending_friendships.includes(:friend)
    end
  end
