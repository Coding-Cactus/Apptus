# frozen_string_literal: true

class Message < ApplicationRecord
  paginates_per 50

  belongs_to :chat, touch: true
  belongs_to :user

  has_many :statuses, dependent: :destroy

  validates :content, presence: true, length: { maximum: 2500 }

  broadcasts_to ->(message) { [message.chat, "messages"] }, inserts_by: :append

  after_create_commit do
    statuses.create(chat.user_ids.map { |id| { user_id: id, status: ("read" if id == user_id) }.compact })
    send_push_notifications unless user.system?
  end

  def lowest_status
    order = Status.statuses.keys
    statuses.reduce("read") do |lowest, status|
      order.index(status.status) < order.index(lowest) ? status.status : lowest
    end
  end

  private
    def send_push_notifications
      PushSubscription.where(user_id: chat.user_ids, subscribed: true).each do |subscription|
        subscription.send_push_notification(
          title: chat.name,
          body: content,
          icon: chat.notification_pfp_url,
          data: { url: Rails.application.routes.url_helpers.chat_url(chat) }
        )
      end
    end
end
