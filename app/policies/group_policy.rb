
class GroupPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(owner: user)
    end
  end

  def new?
    user.present?
  end

  def destroy?
    owner?
  end

  def create?
    owner?
  end

  def show?
    owner? || member_of_group? || shared_with_me?
  end

  private
  def owner?
    record.owner_id == user.id
  end

  def member_of_group?
    false
    # user.groups.include?(record)
  end

  def shared_with_me?
    false
    # record.shared_with.include?(user)
  end
end
