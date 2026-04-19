class PagesController < ApplicationController
  def home
    authorize :page, :home?
    @groups = []

    # shopping_lists are not separately scoped — group access implies list access
    @groups = policy_scope(Group).includes(shopping_lists: :shopping_list_items)
    @list_scope = policy_scope(ShoppingList)
    @recently_visited = ShoppingLists::RecentlyVisited.new(current_user, scope: @list_scope).call.limit(10)
  end
end
