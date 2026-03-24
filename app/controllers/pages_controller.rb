class PagesController < ApplicationController
  def home
    authorize :page, :home?
    @groups = []
    @groups = current_user.groups.to_a if current_user
  end
end
