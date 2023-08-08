# frozen_string_literal: true

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "#new" do
    get new_user_session_path

    assert_response :success

    assert_select "input[name='user[email]']"
    assert_select "input[name='user[password]']"
    assert_select "input[name='user[remember_me]']"
    assert_select "input[type='submit']"
  end

  test "#new: should redirect to chat if logged in" do
    sign_in users(:Kasey)
    get new_user_session_path

    assert_redirected_to chats_path
  end

  test "#create: valid user without remember me" do
    user = users(:Walker)

    post user_session_path, params: { user: { email: user.email, password: "gIc4jjHjMJBWtROm" } }

    assert_redirected_to chats_path
    assert_equal "Signed in successfully.", flash[:notice]
    assert_equal user.id, @controller.current_user.id
    assert @request.cookie_jar.signed[:remember_user_token].nil?
  end

  test "#create: valid user with remember me" do
    user = users(:Kasey)

    post user_session_path, params: { user: { email: user.email, password: "Th7hJl9Plbibloc", remember_me: "1" } }

    assert_redirected_to chats_path
    assert_equal "Signed in successfully.", flash[:notice]
    assert_equal user.id, @controller.current_user.id
    assert_not @request.cookie_jar.signed[:remember_user_token].nil?
  end

  test "#create: user with email doesn't exist" do
    post user_session_path, params: { user: { email: "abcdefg@example.com", password: "password" } }

    assert_response :unprocessable_entity
    assert_equal "Invalid Email or password.", flash[:alert]
  end

  test "#create: incorrect password" do
    user = users(:Buddy)

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    assert_response :unprocessable_entity
    assert_equal "Invalid Email or password.", flash[:alert]
  end

  test "#create: should not allow user to sign in if they are not confirmed" do
    user = users(:Kennith)

    post user_session_path, params: { user: { email: user.email, password: "d4tfm4Wk" } }

    assert_redirected_to new_user_session_path
    assert_equal "You have to confirm your email address before continuing.", flash[:alert]
  end

  test "#create: should not allow blank email" do
    post user_session_path, params: { user: { password: "password" } }

    assert_response :unprocessable_entity
    assert_equal "Invalid Email or password.", flash[:alert]
  end

  test "#create: should not allow blank password" do
    user = users(:Ema)

    post user_session_path, params: { user: { email: user.email } }

    assert_response :unprocessable_entity
    assert_equal "Invalid Email or password.", flash[:alert]
  end

  test "#destroy: should redirect if not logged in" do
    delete destroy_user_session_path

    assert_redirected_to root_path
  end

  test "#destroy: valid" do
    sign_in users(:Kasey)
    delete destroy_user_session_path

    assert_redirected_to root_path
    assert @controller.current_user.nil?
  end
end
