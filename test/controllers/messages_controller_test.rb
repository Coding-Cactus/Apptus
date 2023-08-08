# frozen_string_literal: true

require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  test "#create: should redirect if not logged in" do
    post chat_messages_path(chats(:Chat1)), params: { message: { content: "Hello" } }
    assert_redirected_to new_user_session_path
  end

  test "#create: should create message" do
    sign_in users(:Stanton)

    assert_difference "Message.count", 1 do
      post chat_messages_path(chats(:Chat1)), params: { message: { content: "Hello" } }
    end

    assert_redirected_to chat_path(chats(:Chat1))
  end

  test "#create: should 404 if not in chat" do
    sign_in users(:Roman)

    assert_difference "Message.count", 0 do
      assert_raise ActionController::RoutingError do
        post chat_messages_path(chats(:Chat4)), params: { message: { content: "Hello" } }
      end
    end
  end

  test "#create: should 404 if chat doesn't exist" do
    sign_in users(:Ema)

    assert_difference "Message.count", 0 do
      assert_raise ActionController::RoutingError do
        post chat_messages_path(999), params: { message: { content: "Hello" } }
      end
    end
  end

  test "#create: content length check" do
    sign_in users(:Kasey)

    # < 1: Invalid
    assert_difference "Message.count", 0 do
      post chat_messages_path(chats(:Chat4)), params: { message: { content: "" } }
    end
    assert_response :unprocessable_entity

    # 1: Valid
    assert_difference "Message.count", 1 do
      post chat_messages_path(chats(:Chat4)), params: { message: { content: "a" * 1 } }
    end
    assert_redirected_to chat_path(chats(:Chat4))

    # 2500: Valid
    assert_difference "Message.count", 1 do
      post chat_messages_path(chats(:Chat4)), params: { message: { content: "a" * 2500 } }
    end
    assert_redirected_to chat_path(chats(:Chat4))

    # > 2500: Invalid
    assert_difference "Message.count", 0 do
      post chat_messages_path(chats(:Chat4)), params: { message: { content: "a" * 2501 } }
    end
    assert_response :unprocessable_entity
  end
end
