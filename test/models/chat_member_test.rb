require "test_helper"

class ChatMemberTest < ActiveSupport::TestCase
  test 'valid new chat member' do
    member = ChatMember.new(chat: chats(:Chat3), user: users(:Kasey))

    assert member.valid?
  end

  test 'should not accept chat member without chat' do
    member = ChatMember.new(user: users(:Kasey))

    refute member.valid?
  end

  test 'should not accept chat member without user' do
    member = ChatMember.new(chat: chats(:Chat3))

    refute member.valid?
  end

  test 'should default role to :basic' do
    member = ChatMember.new(chat: chats(:Chat3), user: users(:Kasey))

    assert member.basic?
  end

  test 'should not accept chat member with duplicate chat and user' do
    member = ChatMember.new(chat: chats(:Chat3), user: users(:Walker))

    refute member.valid?
  end

  test 'should not accept chat member with invalid role' do
    assert_raise(ArgumentError) { ChatMember.new(chat: chats(:Chat3), user: users(:Kasey), role: :abcdef) }
  end

  test 'should send message in chat when chat member is created' do
    chat = chats(:Chat3)

    assert_equal 0, chat.messages.length

    chat.chat_members.create(user: users(:Kasey))

    assert_equal 1, chat.messages.length
    assert chat.messages.last.user.system?
    assert_equal "#{users(:Kasey).title_name} was added", chat.messages.last.content
  end

  test 'should send message in chat when chat member is destroyed' do
    chat = chats(:Chat3)
    assert_equal 0, chat.messages.length

    chat.chat_members.find_by(user: users(:Walker)).destroy

    assert_equal 1, chats(:Chat3).messages.length
    assert chat.messages.last.user.system?
    assert_equal "#{users(:Walker).title_name} was removed", chat.messages.last.content
  end

  test 'Chat#role_id' do
    assert_equal 0, chat_members(:WalkerChat3).role_id
    assert_equal 1, chat_members(:BuddyChat3).role_id
  end
end
