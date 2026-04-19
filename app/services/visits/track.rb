module Visits
  class Track
    def self.call(user: user, shopping_list: shopping_list)
      raise ArgumentError, "user is required" unless user.present?
      raise ArgumentError, "shopping list is required" unless shopping_list.present?

      visit = ListVisit.find_or_initialize_by(user_id: user.id, shopping_list_id: shopping_list.id)

      if visit.persisted? && visit.visited_at > 1.hour.ago
        visit.visited_at = Time.zone.now
        visit.save!
      else
        ActiveRecord::Base.transaction do
          visit.visited_at = Time.zone.now
          visit.interaction_count += 1
          visit.save!
        end
      end
    end
  end
end
