
class FriendshipPolicy < ApplicationPolicy
  def confirm?
    record.friend == user && record.pending?
  end
end
