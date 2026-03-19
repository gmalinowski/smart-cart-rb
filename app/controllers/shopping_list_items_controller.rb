
class ShoppingListItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shopping_list

  def create
    @shopping_list.add_item!(shopping_list_item_params[:name])
    redirect_to @shopping_list
  end

  def destroy
      @shopping_list.shopping_list_items.find(params[:id]).destroy
  end

  private

  def set_shopping_list
    @shopping_list = ShoppingList.find(params[:shopping_list_id])
  end

  def shopping_list_item_params
    params.require(:shopping_list_item).permit(:name)
  end
end
