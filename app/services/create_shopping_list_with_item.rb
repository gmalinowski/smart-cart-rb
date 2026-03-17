
class CreateShoppingListWithItem
  def initialize(item_name:, owner_id:)
    @item_name = item_name
    @owner_id = owner_id
  end

  def call
    ActiveRecord::Base.transaction do
      list = ShoppingList.create!(owner_id: @owner_id, name: Date.today.to_s)
      list.shopping_list_items.create!(name: @item_name)
      list
    end
  end
end
