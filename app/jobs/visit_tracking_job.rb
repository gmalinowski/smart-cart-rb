class VisitTrackingJob < ApplicationJob
  queue_as :default

  def perform(user_id:, shopping_list_id:, visited_at:)
    user = User.find(user_id)
    shopping_list = ShoppingList.find(shopping_list_id)

    ListVisit.create!(
      user_id: user.id,
      shopping_list_id: shopping_list.id,
      visited_at: visited_at
    )

  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Error tracking visit: #{e.message}"
  end
end
