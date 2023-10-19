# frozen_string_literal: true

class Message < ApplicationRecord
  paginates_per 50

  belongs_to :chat, touch: true
  belongs_to :user

  has_many :statuses

  validates :content, presence: true, length: { maximum: 2500 }

  broadcasts_to ->(message) { [message.chat, "messages"] }, inserts_by: :append

  def lowest_status
    statuses.reduce("read") do |lowest, status|
      order = %w[read received]
      order.index(status.status) < order.index(lowest) ? status.status : lowest
    end
  end
end
