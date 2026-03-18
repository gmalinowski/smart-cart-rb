
class ListItemsController < ApplicationController
  before_action :authenticate_user!
  def create
    owner_id = current_user.id
    item_name = list_item_params[:name]
    list = CreateShoppingListWithItem.new(item_name: item_name, owner_id: owner_id).call
    redirect_to edit_shopping_lists_path(list)
  end


  private
  def list_item_params
    params.require(:shopping_list_item).permit(:name)
  end
end
