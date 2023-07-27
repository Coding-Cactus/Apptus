# frozen_string_literal: true

require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "valid new message" do
    message = chats(:Chat3).messages.new(user: users(:Ema), content: "Hi!")

    assert message.valid?
  end

  test "invalid without user" do
    message = chats(:Chat3).messages.new(content: "Hello")

    assert_not message.valid?
  end

  test "invalid without content" do
    message = chats(:Chat3).messages.new(user: users(:Kasey))

    assert_not message.valid?
  end

  test "invalid without chat" do
    message = Message.new(user: users(:Kasey), content: "Hello")

    assert_not message.valid?
  end

  test "message content length check" do
    assert chats(:Chat3).messages.new(user: users(:Walker), content: "a").valid?

    assert chats(:Chat3).messages.new(user: users(:Kasey), content: "a" * 2500).valid?

    assert_not chats(:Chat3).messages.new(user: users(:Buddy), content: "a" * 2501).valid?
  end
end
