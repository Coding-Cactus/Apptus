# frozen_string_literal: true

class Status < ApplicationRecord
  belongs_to :user
  belongs_to :message

  enum status: %i[read recieved]

  validates :status, inclusion: { in: statuses.keys }
end
