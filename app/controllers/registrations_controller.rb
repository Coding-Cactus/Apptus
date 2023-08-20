# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  layout "settings", only: :edit
  before_action :set_selected, only: :edit

  def destroy_pfp
    redirect_to new_user_session_path, alert: "You must be signed in to do that." and return unless user_signed_in?

    current_user.pfp.purge
    redirect_to edit_user_registration_path, notice: "Profile picture deleted."
  end

  private
    def set_selected
      @selected = :account
    end
end
