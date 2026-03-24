
class FoldersController < ApplicationController
  before_action :authenticate_user!
  def show
    @drafts = current_user.shopping_lists.drafts.to_a
    @groups = current_user.groups.to_a
  end
end
