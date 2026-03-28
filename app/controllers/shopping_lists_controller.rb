class ShoppingListsController < ApplicationController
  before_action :authenticate_user!, except: []
  skip_after_action :verify_policy_scoped, only: [ :show, :create, :destroy ]

  def show
    @shopping_list = ShoppingList.find(params[:id])
    authorize @shopping_list
    @empty_shopping_list_item = ShoppingListItem.new(shopping_list: @shopping_list)
  end

  def destroy
    authorize ShoppingList.find(params[:id])
    ShoppingList.find(params[:id]).destroy
    redirect_to root_path
  end
  def create
    new_shopping_list = ShoppingList.new
    authorize new_shopping_list
    owner_id = current_user.id
    item_name = list_item_params[:name]
    list = CreateShoppingListWithItem.new(item_name: item_name, owner_id: owner_id).call
    redirect_to list
    rescue ActiveRecord::RecordInvalid
      flash[:alert] = "Could not create shopping list."
      redirect_back fallback_location: root_path
  end

  private

  def list_item_params
    params.require(:shopping_list_item).permit(:name)
  end
end
