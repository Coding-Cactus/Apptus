# frozen_string_literal: true

class ChatMember < ApplicationRecord
  belongs_to :user
  belongs_to :chat

  enum role: %i[basic administrator]

  validates :role, presence: true, inclusion: { in: roles.keys }
  validates :user_id, presence: true, uniqueness: { scope: :chat_id }

  after_create_commit do
    user.push_subscription&.send_push_notification(
      title: "You've been added to a chat",
      body: "You're now a member of '#{chat.name}'",
      icon: chat.notification_pfp_url,
      data: { url: Rails.application.routes.url_helpers.chat_url(chat) }
    )

    chat.messages.create(user_id: User.find_by(role: :system).id, content: "#{user.title_name} was added")

    broadcast_prepend_later_to(
      "user_#{user_id}_chats",
      target: "list",
      partial: "chats/chat_preview",
      locals: { chat:, user:, new_chat: true, redirected_to: chat.owner_id == user_id }
    )
  end

  before_destroy do
    unless destroyed_by_association
      chat.messages.create(user_id: User.find_by(role: :system).id, content: "#{user.title_name} was removed")
    end

    broadcast_remove_to(
      "user_#{user_id}_chats",
      target: "chat_#{chat_id}_wrapper"
    )
  end

  def role_id
    ChatMember.roles[role]
  end
end
