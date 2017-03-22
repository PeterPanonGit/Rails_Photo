class CreditPolicy

  def initialize user, record
    @user = user
    @record = record
  end

  def add?
    @user.present?
  end

end