
class ShoppingListItemPolicy < ApplicationPolicy
  def create?
    ShoppingListPolicy.new(user, record.shopping_list).add_item?
  end

  def destroy?
    ShoppingListPolicy.new(user, record.shopping_list).destroy_item?
  end
  def update?
    ShoppingListPolicy.new(user, record.shopping_list).edit_item?
  end

  def toggle?
    update?
  end
end
