
class GroupShoppingListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shopping_list

  def edit
    authorize @shopping_list
    @group_shopping_lists = @shopping_list.group_shopping_lists
    @groups = policy_scope(Group)
    @all_selected = @shopping_list.group_ids.sort == @groups.pluck(:id).sort
  end

  def update
    authorize @shopping_list
    allowed_params = permitted_attributes(@shopping_list)
    allowed_params[:group_ids] = filter_group_ids(allowed_params[:group_ids])
    if @shopping_list.update(allowed_params)
      flash[:success] = "Shopping list updated"
      redirect_to @shopping_list
    else
      @groups = policy_scope(Group)
      flash[:alert] = "Shopping list could not be updated :("
      render :edit, status: :unprocessable_content
    end
  end

  private

  def filter_group_ids(group_ids)
    ids = Array(group_ids).compact_blank
    policy_scope(Group).where(id: ids).pluck(:id)
  end

  def set_shopping_list
    @shopping_list = ShoppingList.find(params[:shopping_list_id])
  end
  def shopping_list_params
    params.require(:shopping_list).permit(group_ids: [])
  end
end
