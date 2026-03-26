
class ShoppingListItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shopping_list
  skip_after_action :verify_policy_scoped, only: [ :create, :update, :toggle, :destroy ]

  def create
    # @shopping_list_item = @shopping_list.shopping_list_items.new(name: shopping_list_item_params[:name])
    @shopping_list_item = ShoppingListItem.new(shopping_list: @shopping_list, name: shopping_list_item_params[:name])
    authorize @shopping_list_item

    if @shopping_list_item.save
      @empty_shopping_list_item = @shopping_list.shopping_list_items.new
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @shopping_list }
      end
    else
      @empty_shopping_list_item = ShoppingListItem.new(shopping_list: @shopping_list)
      flash[:alert] = "Item could not be added"
      render "shopping_lists/show", status: :unprocessable_content
    end
  end

  def update
    item = @shopping_list.shopping_list_items.find(params[:id])
    authorize item
    item.update!(shopping_list_item_params)
    head :ok
  end

  def toggle
    item = @shopping_list.shopping_list_items.find(params[:id])
    authorize item
    item.toggle!(:checked)
    head :ok
  end

  def destroy
    authorize @shopping_list.shopping_list_items.find(params[:id])
    @shopping_list.shopping_list_items.find(params[:id]).destroy
    head :ok
  end

  private

  def set_shopping_list
    @shopping_list = ShoppingList.find(params[:shopping_list_id])
  end

  def shopping_list_item_params
    params.require(:shopping_list_item).permit(:name)
  end
end
