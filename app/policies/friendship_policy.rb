
class FriendshipPolicy < ApplicationPolicy
  def create?
    user.present?
  end
  def confirm?
    record.friend == user && record.pending?
  end

  def auto_confirm?
    user.present? && record&.user == user && record.pending?
  end

  def destroy?
    record.user == user || record.friend == user
  end
end
