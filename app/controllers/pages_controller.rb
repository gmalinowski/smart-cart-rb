class PagesController < ApplicationController
  def home
    authorize :page, :home?
    @groups = []
    @groups = policy_scope(Group)
  end
end
