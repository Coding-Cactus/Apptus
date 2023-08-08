# frozen_string_literal: true

require "test_helper"

class ChatMemberControllerTest < ActionDispatch::IntegrationTest
  test "#new: should redirect if not logged in" do
    get new_chat_chat_member_path(chats(:Chat1))
    assert_redirected_to new_user_session_path
  end

  test "#new: should get new if owner" do
    sign_in users(:Kasey)

    get new_chat_chat_member_path(chats(:Chat4))

    assert_response :success
    assert_select "a[href='#{edit_chat_path(chats(:Chat4))}'] span", "Back"
    assert_select "a[href='#{pending_contacts_path}'] span", "Add new contacts"
    assert_select "#members-list .member", 1
    assert_select "#members-list .member a[data-turbo-method='post']", 1
  end

  test "#new: should get new if admin" do
    sign_in users(:Walker)

    get new_chat_chat_member_path(chats(:Chat4))

    assert_response :success
    assert_select "a[href='#{edit_chat_path(chats(:Chat4))}'] span", "Back"
    assert_select "a[href='#{pending_contacts_path}'] span", "Add new contacts"
    assert_select "#members-list .member", 1
    assert_select "#members-list .member a[data-turbo-method='post']", 1
  end

  test "#new: should 404 if basic member" do
    sign_in users(:Corrie)

    assert_raise ActionController::RoutingError do
      get new_chat_chat_member_path(chats(:Chat1))
    end
  end

  test "#new: should 404 if not member of chat" do
    sign_in users(:Ema)

    assert_raise ActionController::RoutingError do
      get new_chat_chat_member_path(chats(:Chat2))
    end
  end

  test "#create: should redirect if not logged in" do
    post chat_chat_members_path(chats(:Chat1)), params: { user_id: users(:Walker) }
    assert_redirected_to new_user_session_path
  end

  test "#create: should work for owner" do
    sign_in users(:Kasey)

    assert_difference "ChatMember.count", 1 do
      post chat_chat_members_path(chats(:Chat4)), params: { user_id: users(:Buddy).id }
    end

    assert_redirected_to new_chat_chat_member_path(chats(:Chat4))
    assert_equal "New chat member added", flash[:notice]

    member = ChatMember.last
    assert_equal chats(:Chat4), member.chat
    assert_equal users(:Buddy), member.user
    assert_equal "basic", member.role
  end

  test "#create: should work for admin" do
    sign_in users(:Walker)

    assert_difference "ChatMember.count", 1 do
      post chat_chat_members_path(chats(:Chat4)), params: { user_id: users(:Buddy).id }
    end

    assert_redirected_to new_chat_chat_member_path(chats(:Chat4))
    assert_equal "New chat member added", flash[:notice]

    member = ChatMember.last
    assert_equal chats(:Chat4), member.chat
    assert_equal users(:Buddy), member.user
    assert_equal "basic", member.role
  end

  test "#create: should 404 for basic member" do
    sign_in users(:Ema)

    assert_raise ActionController::RoutingError do
      post chat_chat_members_path(chats(:Chat4)), params: { user_id: users(:Buddy).id }
    end
  end

  test "#create: should 404 if not member of chat" do
    sign_in users(:Stanton)

    assert_raise ActionController::RoutingError do
      post chat_chat_members_path(chats(:Chat4)), params: { user_id: users(:Roman).id }
    end
  end

  test "#create: should not allow unknown user id" do
    sign_in users(:Kasey)


    post chat_chat_members_path(chats(:Chat4)), params: { user_id: 999 }

    assert_response :unprocessable_entity
    assert_equal "Something went wrong when adding that user to the chat", flash[:alert]
  end

  test "#create: should not allow duplicate user id" do
    sign_in users(:Kasey)

    assert_difference "ChatMember.count", 0 do
      post chat_chat_members_path(chats(:Chat4)), params: { user_id: users(:Ema).id }
    end

    assert_response :unprocessable_entity
    assert_equal "Something went wrong when adding that user to the chat", flash[:alert]
  end

  test "#create: should not allow users not in contacts to be added" do
    sign_in users(:Kasey)

    assert_difference "ChatMember.count", 0 do
      post chat_chat_members_path(chats(:Chat4)), params: { user_id: users(:Roman).id }
    end

    assert_response :unprocessable_entity
    assert_equal "Something went wrong when adding that user to the chat", flash[:alert]
  end

  test "#update: should redirect if not logged in" do
    patch chat_chat_member_path(chats(:Chat1), chat_members(:CorrieChat1)), params: { chat_member: { role: "admin" } }
    assert_redirected_to new_user_session_path
  end

  test "#update: should work for owner" do
    sign_in users(:Ema)

    patch chat_chat_member_path(chats(:Chat3), chat_members(:WalkerChat3)), params: { chat_member: { role: "administrator" } }

    assert_redirected_to edit_chat_path(chats(:Chat3))
    assert_equal "Role updated for chat member", flash[:notice]
    assert chat_members(:WalkerChat3).reload.administrator?
  end

  test "#update: should 404 for admin" do
    sign_in users(:Buddy)

    assert_raise ActionController::RoutingError do
      patch chat_chat_member_path(chats(:Chat3), chat_members(:WalkerChat3)), params: { chat_member: { role: "administrator" } }
    end
  end

  test "#update: should 404 for basic member" do
    sign_in users(:Corrie)

    assert_raise ActionController::RoutingError do
      patch chat_chat_member_path(chats(:Chat1), chat_members(:StantonChat1)), params: { chat_member: { role: "administrator" } }
    end
  end

  test "#update: should 404 if not member of chat" do
    sign_in users(:Stanton)

    assert_raise ActionController::RoutingError do
      patch chat_chat_member_path(chats(:Chat3), chat_members(:WalkerChat3)), params: { chat_member: { role: "administrator" } }
    end
  end

  test "#update: should not allow invalid role" do
    sign_in users(:Kasey)

    assert_raise ArgumentError do
      patch chat_chat_member_path(chats(:Chat4), chat_members(:EmaChat4)), params: { chat_member: { role: "invalid" } }
    end

    assert chat_members(:EmaChat4).reload.basic?
  end

  test "#update: should fail for non existent chat member" do
    sign_in users(:Kasey)

    assert_raise ActiveRecord::RecordNotFound do
      patch chat_chat_member_path(chats(:Chat4), 999), params: { chat_member: { role: "administrator" } }
    end
  end

  test "#destroy: should redirect if not logged in" do
    delete chat_chat_member_path(chats(:Chat1), chat_members(:CorrieChat1))
    assert_redirected_to new_user_session_path
  end

  test "#destroy: should work for owner on any member" do
    sign_in users(:Earlie)

    # Admin
    assert_difference "ChatMember.count", -1 do
      delete chat_chat_member_path(chats(:Chat2), chat_members(:RomanChat2))
    end

    assert_redirected_to edit_chat_path(chats(:Chat2))
    assert_equal "Chat member removed", flash[:notice]

    # Basic
    assert_difference "ChatMember.count", -1 do
      delete chat_chat_member_path(chats(:Chat2), chat_members(:StantonChat2))
    end

    assert_redirected_to edit_chat_path(chats(:Chat2))
    assert_equal "Chat member removed", flash[:notice]
  end

  test "#destroy: should work for admin on basic member" do
    sign_in users(:Buddy)

    assert_difference "ChatMember.count", -1 do
      delete chat_chat_member_path(chats(:Chat3), chat_members(:WalkerChat3))
    end

    assert_redirected_to edit_chat_path(chats(:Chat3))
    assert_equal "Chat member removed", flash[:notice]
  end

  test "#destroy: should 404 for admin on owner" do
    sign_in users(:Corrie)

    assert_raise ActionController::RoutingError do
      delete chat_chat_member_path(chats(:Chat2), chat_members(:EarlieChat2))
    end
  end

  test "#destroy: should 404 for admin on admin" do
    sign_in users(:Roman)

    assert_raise ActionController::RoutingError do
      delete chat_chat_member_path(chats(:Chat2), chat_members(:CorrieChat2))
    end
  end

  test "#destroy: should 404 for basic member on owner" do
    sign_in users(:Stanton)

    assert_raise ActionController::RoutingError do
      delete chat_chat_member_path(chats(:Chat2), chat_members(:EarlieChat2))
    end
  end

  test "#destroy: should 404 for basic member on admin" do
    sign_in users(:Stanton)

    assert_raise ActionController::RoutingError do
      delete chat_chat_member_path(chats(:Chat2), chat_members(:RomanChat2))
    end
  end

  test "#destroy: should 404 for basic member on basic member" do
    sign_in users(:Stanton)

    assert_raise ActionController::RoutingError do
      delete chat_chat_member_path(chats(:Chat1), chat_members(:CorrieChat1))
    end
  end

  test "#destroy: should 404 if not member of chat" do
    sign_in users(:Stanton)

    assert_raise ActionController::RoutingError do
      delete chat_chat_member_path(chats(:Chat3), chat_members(:WalkerChat3))
    end
  end

  test "#destroy: should fail for non existent chat member" do
    sign_in users(:Kasey)

    assert_raise ActiveRecord::RecordNotFound do
      delete chat_chat_member_path(chats(:Chat4), 999)
    end
  end

  test "#destroy: should not allow member to be removed if there are only 2 members" do
    sign_in users(:Walker)

    assert_difference "ChatMember.count", 0 do
      delete chat_chat_member_path(chats(:Chat5), chat_members(:EmaChat5))
    end

    assert_redirected_to edit_chat_path(chats(:Chat5))
    assert_equal "Cannot have less than 2 people in a chat", flash[:alert]
  end
end
