# frozen_string_literal: true

class PushSubscription < ApplicationRecord
  validates :endpoint, presence: true
  validates :p256dh, presence: true
  validates :auth, presence: true

  def send_push_notification(**options)
    NewMessagePushNotificationJob.perform_later(
      message: JSON.generate(options),
      endpoint:,
      p256dh:,
      auth:,
      vapid: {
        subject: "mailto:push@#{ENV['APPTUS_EMAIL_HOST']}",
        public_key: VAPID_PUBLIC_KEY,
        private_key: VAPID_PRIVATE_KEY
      }
    )
  end
end
