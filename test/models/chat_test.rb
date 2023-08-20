# frozen_string_literal: true

require "test_helper"

class ChatTest < ActiveSupport::TestCase
  test "valid new chat" do
    chat = Chat.new(
      name: "Test Chat",
      owner: users(:Buddy),
      users: [users(:Buddy), users(:Ema), users(:Kasey), users(:Walker)]
    )

    assert chat.valid?
  end

  test "should not accept chat without name" do
    chat = Chat.new(
      owner: users(:Buddy),
      users: [users(:Buddy), users(:Walker)]
    )

    assert_not chat.valid?
  end

  test "should not accept chat without owner" do
    chat = Chat.new(
      name: "Test Chat",
      users: [users(:Buddy), users(:Walker)]
    )

    assert_not chat.valid?
  end

  test "should not accept chat with less than 2 users" do
    chat = Chat.new(
      name: "Test Chat",
      owner: users(:Buddy),
      users: [users(:Buddy)]
    )

    assert_not chat.valid?
  end

  test "should accept chat with 2 users" do
    chat = Chat.new(
      name: "Test Chat",
      owner: users(:Walker),
      users: [users(:Walker), users(:Ema)]
    )

    assert chat.valid?
  end

  test "chat name length check" do
    assert_not Chat.new(
      name: "",
      owner: users(:Walker),
      users: [users(:Walker), users(:Buddy), users(:Ema)]
    ).valid?

    assert Chat.new(
      name: "a",
      owner: users(:Ema),
      users: [users(:Ema), users(:Kasey), users(:Walker)]
    ).valid?

    assert Chat.new(
      name: "a" * 30,
      owner: users(:Kasey),
      users: [users(:Kasey), users(:Ema)]
    ).valid?

    assert_not Chat.new(
      name: "a" * 31,
      owner: users(:Buddy),
      users: [users(:Buddy), users(:Walker)]
    ).valid?
  end

  test "should assign colour to newly created chat" do
    chat = Chat.create(
      name: "Test Chat",
      owner: users(:Ema),
      users: [users(:Ema), users(:Kasey), users(:Walker)]
    )

    assert_not chat.colour.nil?
  end

  test "colour should be 6 digit hex format" do
    chat = Chat.create(
      name: "Test Chat",
      owner: users(:Walker),
      users: [users(:Walker), users(:Buddy)]
    )

    assert chat.colour.match?(/#[A-F0-9]{6}/)
  end

  test "system message created after new chat created" do
    chat = Chat.create(
      name: "Test Chat",
      owner: users(:Walker),
      users: [users(:Walker), users(:Ema)]
    )

    assert chat.messages.first.user.system?
    assert_equal "Chat created", chat.messages.first.content
  end

  test "Chat#initials" do
    assert_equal "TC", chats(:Chat1).initials

    chat = Chat.create(
      name: "random chatting group",
      owner: users(:Walker),
      users: [users(:Walker), users(:Buddy)]
    )

    assert_equal "RC", chat.initials
  end

  test "Chat#add_initial_users: valid" do
    chat = users(:Ema).owned_chats.new(name: "My Chat")

    chat.add_initial_users(users(:Ema), [users(:Kasey), users(:Walker)].map(&:id))

    assert_equal 3, chat.users.length
    assert_equal [users(:Ema), users(:Kasey), users(:Walker)], chat.users
    assert chat.valid?
  end

  test "Chat#add_initial_users: should not accept users who are not in contacts" do
    chat = users(:Kasey).owned_chats.new(name: "Chatting")

    chat.add_initial_users(users(:Kasey), [users(:Buddy), users(:Corrie)].map(&:id))

    assert_equal 2, chat.users.length
    assert_equal [users(:Kasey), users(:Buddy)], chat.users
    assert chat.valid?

    chat = users(:Walker).owned_chats.new(name: "Chat")

    chat.add_initial_users(users(:Walker), [users(:Stanton), users(:Earlie)].map(&:id))

    assert_equal 1, chat.users.length
    assert_equal [users(:Walker)], chat.users
    assert_not chat.valid?
  end

  test "Chat#add_initial_users: should not accept users who are already in chat" do
    chat = users(:Ema).owned_chats.new(name: "My Chat")

    chat.add_initial_users(users(:Ema), [users(:Kasey), users(:Walker)].map(&:id))

    assert_equal 3, chat.users.length
    assert_equal [users(:Ema), users(:Kasey), users(:Walker)], chat.users
    assert chat.save

    chat.add_initial_users(users(:Ema), [users(:Buddy), users(:Kasey)].map(&:id))

    assert_equal 4, chat.users.length
    assert_equal [users(:Ema), users(:Kasey), users(:Walker), users(:Buddy)], chat.users
  end

  test "Chat#add_new_member: valid" do
    chat = chats(:Chat3)

    assert chat.add_new_member(users(:Ema), users(:Kasey).id)
  end

  test "Chat#add_new_member: should not accept user who is not in contacts" do
    chat = chats(:Chat3)

    assert_not chat.add_new_member(users(:Ema), users(:Roman).id)
  end

  test "Chat#add_new_member: should not accept user who is already in chat" do
    chat = chats(:Chat3)

    assert_not chat.add_new_member(users(:Ema), users(:Buddy).id)
  end

  test "Chat#administrators" do
    assert_equal [], chats(:Chat1).administrators
    assert_equal [users(:Buddy)], chats(:Chat3).administrators
    assert_equal [users(:Roman), users(:Corrie)], chats(:Chat2).administrators
  end

  test "Chat#administrator_ids" do
    assert_equal [], chats(:Chat1).administrator_ids
    assert_equal [users(:Buddy)].map(&:id), chats(:Chat3).administrator_ids
    assert_equal [users(:Roman), users(:Corrie)].map(&:id), chats(:Chat2).administrator_ids
  end

  test "messages destroyed after chat destroyed" do
    chat = chats(:Chat1)
    message_ids = chat.message_ids

    assert_equal 3, message_ids.length

    chat.destroy

    assert_equal 0, Message.where(id: message_ids).length
  end

  test "chat_members destroyed after chat destroyed" do
    chat = chats(:Chat3)
    chat_member_ids = chat.user_ids

    assert_equal 3, chat_member_ids.length

    chat.destroy

    assert_equal 0, ChatMember.where(id: chat_member_ids).length
  end

  test "#pfp_thumbnail" do
    # should resize jpg
    chat = chats(:Chat1)
    assert_equal chat.pfp_thumbnail.variation.transformations[:resize_to_limit], [175, 175]

    # should not resize gif
    chat = chats(:Chat5)
    assert_raises(NoMethodError) { chat.pfp_thumbnail.variation }
  end
end
