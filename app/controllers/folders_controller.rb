
class FoldersController < ApplicationController
  before_action :authenticate_user!
  def show
    authorize :folder, :show?
    # @drafts = current_user.shopping_lists.drafts.to_a
    @drafts = policy_scope(ShoppingList)
    # @groups = current_user.groups.to_a
    @groups = policy_scope(Group)
  end
end
