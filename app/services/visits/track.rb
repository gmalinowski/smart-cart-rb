module Visits
  class Track
    def self.call(user: user, shopping_list: shopping_list)
      raise ArgumentError, "user is required" unless user.present?
      raise ArgumentError, "shopping list is required" unless shopping_list.present?
      return if user.last_visited_shopping_list&.id == shopping_list.id
      VisitTrackingJob.perform_later(user_id: user.id, shopping_list_id: shopping_list.id, visited_at: Time.zone.now)
    end
  end
end
