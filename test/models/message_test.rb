require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test 'valid new message' do
    message = chats(:Chat3).messages.new(user: users(:Ema), content: 'Hi!')

    assert message.valid?
  end

  test 'invalid without user' do
    message = chats(:Chat3).messages.new(content: 'Hello')

    refute message.valid?
  end

  test 'invalid without content' do
    message = chats(:Chat3).messages.new(user: users(:Kasey))

    refute message.valid?
  end

  test 'invalid without chat' do
    message = Message.new(user: users(:Kasey), content: 'Hello')

    refute message.valid?
  end

  test 'message content length check' do
    assert chats(:Chat3).messages.new(user: users(:Walker), content: 'a').valid?

    assert chats(:Chat3).messages.new(user: users(:Kasey), content: 'a' * 2500).valid?

    refute chats(:Chat3).messages.new(user: users(:Buddy), content: 'a' * 2501).valid?
  end
end
