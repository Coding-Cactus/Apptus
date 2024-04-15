class NewContactRequestEmailJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordNotFound

  def perform(contact_request_id)
    contact_request = Contact.find(contact_request_id)

    unless contact_request.nil? || contact_request.accepted?
      UserMailer.with(target: contact_request.target, creator: contact_request.creator).contact_request.deliver_now
    end
  end
end
