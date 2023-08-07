# frozen_string_literal: true

class Contact < ApplicationRecord
  belongs_to :target,  class_name: "User"
  belongs_to :creator, class_name: "User"
  validate :contact_request_already_exists, on: :create

  enum status: %i[pending accepted]

  validates :status, inclusion: { in: statuses.keys }

  private
    def contact_request_already_exists
      if Contact.where(creator:, target:).any? || Contact.where(creator: target, target: creator).any?
        errors.add(:base, "Contact request already exists")
      end
    end
end
