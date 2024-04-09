class NewMessagePushNotificationJob < ApplicationJob
  queue_as :default

  def perform(**options)
    WebPush.payload_send(**options)
  end
end
