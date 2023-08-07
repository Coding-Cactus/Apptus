# frozen_string_literal: true

class ContactsController < ApplicationController
  layout "settings"

  before_action :set_selected
  before_action :authenticate_user!
  before_action :check_contact_exists, only: %i[update destroy]

  def index
    @contacts = current_user.contacts.order("LOWER(name)")
  end

  def new
    @new_contact       = Contact.new
    @incoming_requests = current_user.incoming_contact_requests.order("LOWER(name)")
    @outgoing_requests = current_user.outgoing_contact_requests.order("LOWER(name)")
  end

  def create
    target = User.find_by(contact_number:)
    contact = Contact.new(creator: current_user, target:)

    if target != current_user && contact.save
      flash[:notice] = "Contact request sent successfully"
    else
      flash[:alert] = "Couldn't find a user with that contact number"
    end

    redirect_to :pending_contacts
  end

  # Contact request accepted
  def update
    @contact.update(status: :accepted)
    flash[:notice] = "Contact request accepted"
    redirect_to :pending_contacts
  end

  # Contact request denied
  def destroy
    @contact.destroy
    flash[:alert] = "Contact request denied"
    redirect_to :pending_contacts
  end

  private
    def set_selected
      @selected = :contacts
    end

    def contact_number
      params.require(:contact).permit(:contact_number)[:contact_number].delete("-")
    end

    def check_contact_exists
      @contact = current_user.find_contact(params[:id]) || not_found
    end
end
