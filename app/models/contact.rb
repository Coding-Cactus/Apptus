# frozen_string_literal: true

class Contact < ApplicationRecord
  belongs_to :target,  class_name: "User"
  belongs_to :creator, class_name: "User"
  validate :contact_request_already_exists, on: :create

  enum status: %i[pending accepted]

  validates :status, inclusion: { in: statuses.keys }

  after_create_commit do
    target.push_subscription&.send_push_notification(
      title: "New contact request",
      body: "#{creator.title_name} would like to be added to your contacts.",
      icon: creator.notification_pfp_url,
      data: { url: Rails.application.routes.url_helpers.pending_contacts_url }
    )
    NewContactRequestEmailJob.set(wait: 1.hour).perform_later(id)
  end

  private
    def contact_request_already_exists
      if Contact.where(creator:, target:).any? || Contact.where(creator: target, target: creator).any?
        errors.add(:base, "Contact request already exists")
      end
    end
end
