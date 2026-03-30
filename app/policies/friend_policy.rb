
class FriendPolicy < ApplicationPolicy

  def index?
    user.present?
  end
end