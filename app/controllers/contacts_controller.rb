class ContactsController < ApplicationController
  layout 'settings'

  before_action :set_selected
  before_action :authenticate_user!
  before_action :check_contact_exists, only: %i[update destroy]

  def index
    @contacts = current_user.contacts.includes(:creator, :target)
                            .map { |c| [c.id, c.target_id == current_user.id ? c.creator : c.target] }
                            .sort_by { |_, c| c.title_name }
  end

  def new
    @new_contact       = Contact.new
    @incoming_requests = current_user.incoming_contact_requests.includes(:creator).map { |c| [c.id, c.creator] }
    @outgoing_requests = current_user.outgoing_contact_requests.includes(:target).map  { |c| [c.id, c.target]  }
  end

  def create
    target = User.find_by(contact_number:)

    if !target.nil? && target.id != current_user.id
      Contact.create(creator_id: current_user.id, target_id: target.id, status: 'pending')
      flash[:notice] = 'Contact request sent successfully'
    else
      flash[:alert] = 'Couldn\'t find a user with that contact number'
    end

    redirect_to :pending_contacts
  end

  # Contact request accepted
  def update
    @contact.update(status: 'accepted')
    flash[:notice] = 'Contact request accepted'
    redirect_to :pending_contacts
  end

  # Contact request denied
  def destroy
    @contact.destroy
    flash[:alert] = 'Contact request denied'
    redirect_to :pending_contacts
  end

  private

  def set_selected
    @selected = :contacts
  end

  def contact_number
    params.require(:contact).permit(:contact_number)[:contact_number].gsub('-', '')
  end

  def check_contact_exists
    @contact = Contact.find_by(id: params[:id]) || not_found
  end
end
