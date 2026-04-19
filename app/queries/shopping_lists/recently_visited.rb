module ShoppingLists
  class RecentlyVisited
    def initialize(user, scope:)
      @user = user
      @scope = scope
    end

    def call
      @scope.joins(:list_visits)
            .where(list_visits: { user: @user })
            .order(list_visits: { visited_at: :desc })
    end
  end
end
