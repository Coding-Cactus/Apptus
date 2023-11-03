# frozen_string_literal: true

class MessagesStatusesChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
