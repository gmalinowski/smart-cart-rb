
class ShoppingListPolicy < ApplicationPolicy
  def permitted_attributes
    return [] unless owner?
    [ :name, :description, { group_ids: [] } ]
  end
  class Scope < Scope
    def resolve
      scope.where(owner: user)
      # PÓŹNIEJ (gdy dojdzie share):
      # scope.left_outer_joins(:shared_users, :group)
      #      .where("shopping_lists.owner_id = ? OR shared_users.id = ? OR groups.user_id = ?", user.id, user.id, user.id)
      #      .distinct
    end
  end
  def index?
  end
  def new?
    create?
  end
  def create?
    user.present?
  end
  def show?
    owner? || member_of_assigned_group? || shared_with_me?
  end
  def edit?
    update?
  end

  def destroy_item?
    update?
  end
  def update?
    owner? || member_of_assigned_group? || shared_with_me?
  end

  def add_item?
    owner? || member_of_assigned_group? || shared_with_me?
  end

  def edit_item?
    add_item?
  end

  private
  def owner?
    record.owner_id == user.id
  end

  def member_of_assigned_group?
    false
    # user.groups.include?(record.group)
  end

  def shared_with_me?
    false
    # record.shared_with.include?(user)
  end
end
