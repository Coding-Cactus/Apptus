# frozen_string_literal: true

class Message < ApplicationRecord
  paginates_per 50

  belongs_to :chat, touch: true
  belongs_to :user

  has_many :statuses

  validates :content, presence: true, length: { maximum: 2500 }

  broadcasts_to ->(message) { [message.chat, "messages"] }, inserts_by: :append

  after_create_commit do
    statuses.create(chat.user_ids.map { |id| { user_id: id, status: ("read" if id == user_id) }.compact })
  end

  def lowest_status
    order = Status.statuses.keys
    statuses.reduce("read") do |lowest, status|
      order.index(status.status) < order.index(lowest) ? status.status : lowest
    end
  end
end
