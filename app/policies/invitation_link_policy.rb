
class InvitationLinkPolicy < ApplicationPolicy
  def create?
    owner?
  end

  def destroy?
    owner?
  end

  private

  def owner?
    user.present? &&
    record.user_id == user.id
  end
end
