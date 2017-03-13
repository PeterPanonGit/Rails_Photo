class CommentPolicy < ApplicationPolicy

  def create
    user.present?
  end

  def destroy
    user.present? && (user.admin? || record.client == user)
  end

end