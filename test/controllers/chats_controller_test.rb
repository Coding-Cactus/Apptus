# frozen_string_literal: true

require "test_helper"

class ChatsControllerTest < ActionDispatch::IntegrationTest
  test "#index: should redirect if not logged in" do
    get chats_path
    assert_redirected_to new_user_session_path
  end

  test "#index: should get index when logged in" do
    sign_in users(:Stanton)

    get chats_path

    assert_response :success
    assert_select "#chat-placeholder h2", "Welcome to Apptus"
    assert_select ".chat-preview", 2
  end

  test "#new: should redirect if not logged in" do
    get new_chat_path
    assert_redirected_to new_user_session_path
  end

  test "#new: should get new when logged in" do
    sign_in users(:Ema)

    get new_chat_path

    assert_response :success
    assert_select "input[name='chat[name]']"
    assert_select "input[type='submit']"
    assert_select "#members-list input", 3
    assert_select "a[href='#{pending_contacts_path}']", "+ Add new contacts"
  end

  test "#create: should redirect if not logged in" do
    post chats_path, params: { chat: { name: "Test Chat", user_ids: [users(:Walker).id] } }

    assert_redirected_to new_user_session_path
  end

  test "#create: should create chat when logged in" do
    sign_in users(:Walker)

    assert_difference "Chat.count", 1 do
      post chats_path, params: { chat: { name: "My chat", users: [users(:Ema).id, users(:Kasey).id] } }
    end

    assert_redirected_to chat_path(Chat.last)
    assert_equal "Chat successfully created", flash[:notice]
    assert_equal "My chat", Chat.last.name

    members = Chat.last.users
    assert_equal 3, members.length
    assert members.include?(users(:Walker))
    assert members.include?(users(:Ema))
    assert members.include?(users(:Kasey))
  end

  test "#create: should not create chat with no name" do
    sign_in users(:Kasey)

    post chats_path, params: { chat: { users: [users(:Ema).id, users(:Walker).id] } }

    assert_response :unprocessable_entity
  end

  test "#create: name length  check" do
    sign_in users(:Buddy)

    # < 1: Invalid
    post chats_path, params: { chat: { name: "", users: [users(:Ema).id] } }
    assert_response :unprocessable_entity

    # 1: Valid
    post chats_path, params: { chat: { name: "a", users: [users(:Ema).id] } }
    assert_redirected_to chat_path(Chat.last)

    # 30: Valid
    post chats_path, params: { chat: { name: "a" * 30, users: [users(:Ema).id] } }
    assert_redirected_to chat_path(Chat.last)

    # > 30: Invalid
    post chats_path, params: { chat: { name: "a" * 31, users: [users(:Ema).id] } }
    assert_response :unprocessable_entity
  end

  test "#create: should not create chat with no users" do
    sign_in users(:Walker)

    post chats_path, params: { chat: { name: "My chat" } }

    assert_response :unprocessable_entity
  end

  test "#create: should not allow users to be added who arent accepted contacts" do
    sign_in users(:Walker)

    post chats_path, params: { chat: { name: "My chat", users: [users(:Ema).id, users(:Kasey).id, users(:Stanton).id] } }

    assert_redirected_to chat_path(Chat.last)
    assert_equal 3, Chat.last.users.count
    assert_not Chat.last.users.ids.include?(users(:Stanton).id)

    post chats_path, params: { chat: { name: "My chat", users: [users(:Kennith)] } }
    assert_response :unprocessable_entity
  end

  test "#show: should redirect if not logged in" do
    get chat_path(chats(:Chat1))
    assert_redirected_to new_user_session_path
  end

  test "#show: should show chat when logged in" do
    sign_in users(:Stanton)

    get chat_path(chats(:Chat1))

    assert_response :success
    assert_select ".message", 2
    assert_select "form[action='#{chat_messages_path(chats(:Chat1))}']"
    assert_select ".chat-preview.selected .chat-preview-header span", "Test Chat 1"
  end

  test "#show: should 404 when not a member of chat" do
    sign_in users(:Ema)

    assert_raise ActionController::RoutingError do
      get chat_path(chats(:Chat1))
    end
  end

  test "#show: should 404 when chat does not exist" do
    sign_in users(:Ema)

    assert_raise ActionController::RoutingError do
      get chat_path(999)
    end
  end

  test "#edit: should redirect if not logged in" do
    get edit_chat_path(chats(:Chat1))
    assert_redirected_to new_user_session_path
  end

  test "#edit: should 404 if not member of chat" do
    sign_in users(:Ema)

    assert_raise ActionController::RoutingError do
      get edit_chat_path(chats(:Chat1))
    end
  end

  test "#edit: should 404 if chat does not exist" do
    sign_in users(:Ema)

    assert_raise ActionController::RoutingError do
      get edit_chat_path(999)
    end
  end

  test "#edit: should get edit when logged in as owner, and show:  add members, role dropdowns, member removal, and chat delete" do
    sign_in users(:Roman)

    get edit_chat_path(chats(:Chat1))

    assert_response :success
    assert_select "input[name='chat[name]']"
    assert_select "input[type='submit']"
    assert_select "#members-list input[name='chat_member[role]']", 2
    assert_select "#members-list a[data-turbo-method='delete'].remove", 2
    assert_select "a[href='#{new_chat_chat_member_path(chats(:Chat1))}']", "Add new members"
  end

  test "#edit: should get edit when logged in as admin, and show only: add and remove members" do
    sign_in users(:Corrie)

    get edit_chat_path(chats(:Chat2))

    assert_response :success
    assert_select "input[name='chat[name]']"
    assert_select "input[type='submit']"
    assert_select "#members-list input[name='chat_member[role]']", 0
    assert_select "#members-list a[data-turbo-method='delete'].remove", 1
    assert_select "a[href='#{new_chat_chat_member_path(chats(:Chat2))}']", "Add new members"
  end

  test "#edit: should get edit when logged in as basic, and show no configuration options" do
    sign_in users(:Walker)

    get edit_chat_path(chats(:Chat3))

    assert_response :success
    assert_select "input[name='chat[name]']", 0
    assert_select "input[type='submit']", 0
    assert_select "#members-list input[name='chat_member[role]']", 0
    assert_select "#members-list a[data-turbo-method='delete'].remove", 0
    assert_select "a[href='#{new_chat_chat_member_path(chats(:Chat3))}']", 0
  end

  test "#update: should redirect if not logged in" do
    patch chat_path(chats(:Chat1)), params: { chat: { name: "New name" } }
    assert_redirected_to new_user_session_path
  end

  test "#update: owner can update chat" do
    sign_in users(:Roman)

    patch chat_path(chats(:Chat1)), params: { chat: { name: "New name" } }

    assert_redirected_to edit_chat_path(chats(:Chat1))
    assert_equal "New name", chats(:Chat1).reload.name
    assert_equal "Chat updated", flash[:notice]
  end

  test "#update: admin can update chat" do
    sign_in users(:Buddy)

    patch chat_path(chats(:Chat3)), params: { chat: { name: "New name" } }

    assert_redirected_to edit_chat_path(chats(:Chat3))
    assert_equal "New name", chats(:Chat3).reload.name
    assert_equal "Chat updated", flash[:notice]
  end

  test "#update: basic member cannot update chat" do
    sign_in users(:Walker)

    assert_raise ActionController::RoutingError do
      patch chat_path(chats(:Chat3)), params: { chat: { name: "New name" } }
    end
  end

  test "#update: should 404 for users not in chat" do
    sign_in users(:Ema)

    assert_raise ActionController::RoutingError do
      patch chat_path(chats(:Chat1)), params: { chat: { name: "New name" } }
    end
  end

  test "#update: should 404 for chats that do not exist" do
    sign_in users(:Ema)

    assert_raise ActionController::RoutingError do
      patch chat_path(999), params: { chat: { name: "New name" } }
    end
  end

  test "#update: name length check" do
    sign_in users(:Earlie)

    # < 1: Invalid
    patch chat_path(chats(:Chat2)), params: { chat: { name: "" } }
    assert_response :unprocessable_entity

    # 1: Valid
    patch chat_path(chats(:Chat2)), params: { chat: { name: "a" } }
    assert_redirected_to edit_chat_path(chats(:Chat2))

    # 30: Valid
    patch chat_path(chats(:Chat2)), params: { chat: { name: "a" * 30 } }
    assert_redirected_to edit_chat_path(chats(:Chat2))

    # > 30: Invalid
    patch chat_path(chats(:Chat2)), params: { chat: { name: "a" * 31 } }
    assert_response :unprocessable_entity
  end

  test "#destroy: should redirect if not logged in" do
    delete chat_path(chats(:Chat1))
    assert_redirected_to new_user_session_path
  end

  test "#destroy: should 404 if not member of chat" do
    sign_in users(:Ema)

    assert_raise ActionController::RoutingError do
      delete chat_path(chats(:Chat1))
    end
  end

  test "#destroy: should 404 if chat does not exist" do
    sign_in users(:Ema)

    assert_raise ActionController::RoutingError do
      delete chat_path(999)
    end
  end

  test "#destroy: should 404 if member not owner" do
    # Admin
    sign_in users(:Buddy)
    assert_no_difference "Chat.count" do
      assert_raise ActionController::RoutingError do
        delete chat_path(chats(:Chat3))
      end
    end

    # Basic
    sign_in users(:Walker)
    assert_no_difference "Chat.count" do
      assert_raise ActionController::RoutingError do
        delete chat_path(chats(:Chat3))
      end
    end
  end

  test "#destroy: should delete chat if owner" do
    sign_in users(:Roman)

    assert_difference "Chat.count", -1 do
      delete chat_path(chats(:Chat1))
    end

    assert_redirected_to root_path
    assert_equal "Chat successfully deleted", flash[:notice]
  end
end
