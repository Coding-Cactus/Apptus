class RegistrationsController < Devise::RegistrationsController
  layout 'settings', only: :edit
  before_action :set_selected, only: :edit

  private

  def set_selected
    @selected = :account
  end
end
