  class FriendsController < ApplicationController
    before_action :authenticate_user!
    skip_after_action :verify_policy_scoped, only: [ :show ]

    def show
      authorize :friend, :index?
      @friends = current_user.friends
    end
  end
