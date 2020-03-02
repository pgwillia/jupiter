class ThesisPolicy < DepositablePolicy

  def index?
    true
  end

  def show?
    owned? || admin? || public? || record_requires_authentication?
  end

  def new?
    admin?
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  def download?
    admin? || owned? || public? || user_is_authenticated_for_record?
  end

  def thumbnail?
    download?
  end

  # These policies are used for the AIP V1 API. Pundit does not allow use of
  # namespaces

  def show_entity?
    api? || admin?
  end

  def file_sets?
    api? || admin?
  end

  def file_paths?
    api? || admin?
  end

end
