
class FriendshipPolicy < ApplicationPolicy
  def confirm?
    record.friend == user && record.pending?
  end

  def destroy?
    record.user == user || record.friend == user
  end
end
