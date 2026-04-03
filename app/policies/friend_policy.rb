
class FriendPolicy < ApplicationPolicy
  def show?
    user.present?
  end
end
