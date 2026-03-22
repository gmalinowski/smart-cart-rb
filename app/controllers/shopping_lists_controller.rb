
class ShoppingListsController < ApplicationController
  before_action :authenticate_user!, except: []

  def show
    @shopping_list = ShoppingList.find(params[:id])
    @empty_shopping_list_item = ShoppingListItem.new(shopping_list: @shopping_list)
  end

  def create
    owner_id = current_user.id
    item_name = list_item_params[:name]
    list = CreateShoppingListWithItem.new(item_name: item_name, owner_id: owner_id).call
    redirect_to shopping_list_path(list)
  end


  private
  def list_item_params
    params.require(:shopping_list_item).permit(:name)
  end
end
