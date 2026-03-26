
class FolderPolicy < ApplicationPolicy
  def show?
    user.present?
  end
end
