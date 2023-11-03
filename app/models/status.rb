# frozen_string_literal: true

class Status < ApplicationRecord
  belongs_to :user
  belongs_to :message

  enum status: %i[received read]

  validates :status, inclusion: { in: statuses.keys }
end
