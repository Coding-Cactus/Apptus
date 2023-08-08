# frozen_string_literal: true

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "#new" do
    get new_user_password_path

    assert_response :success
    assert_select "input[name='user[email]']"
    assert_select "input[type='submit']"
  end

  test "#new: redirects if already signed in" do
    sign_in users(:Kasey)
    get new_user_password_path

    assert_redirected_to chats_path
    assert_equal "You are already signed in.", flash[:alert]
  end

  test "#create: should send email" do
    user = users(:Buddy)

    post set_password_path, params: { user: { email: user.email } }

    assert_redirected_to new_user_session_path
    assert_equal(
      "You will receive an email with instructions on how to reset your password in a few minutes.",
      flash[:notice]
    )

    user = user.reload
    assert_not user.reset_password_token.nil?

    email = Devise::Mailer.deliveries.last

    assert_equal [user.email], email.to
    assert_equal "Reset password instructions", email.subject
    assert Nokogiri::HTML.parse(email.body.raw_source).css("a").any? do |a|
      token = Rack::Utils.parse_query(URI(a["href"]).query)["reset_password_token"]
      Devise.token_generator.digest(User, :reset_password_token, token) == user.reset_password_token
    end
  end

  test "#create: doesn't send email for invalid email" do
    # Invalid email
    post set_password_path, params: { user: { email: "abc" } }
    assert_response :unprocessable_entity
    assert_equal 0, Devise::Mailer.deliveries.length

    # Email not found
    post set_password_path, params: { user: { email: "abcdefg@example.com" } }
    assert_response :unprocessable_entity
    assert_equal 0, Devise::Mailer.deliveries.length

    # Blank email
    post set_password_path, params: { user: {} }
    assert_response :unprocessable_entity
    assert_equal 0, Devise::Mailer.deliveries.length
  end

  test "#edit: should render form" do
    user = users(:Ema)
    token = user.send(:set_reset_password_token)

    get edit_user_password_path(reset_password_token: token)

    assert_response :success
    assert_select "input[name='user[password]']"
    assert_select "input[name='user[password_confirmation]']"
    assert_select "input[type='submit']"
  end

  test "#edit: redirects if already signed in" do
    user = users(:Kasey)
    sign_in user
    token = user.send(:set_reset_password_token)

    get edit_user_password_path(reset_password_token: token)

    assert_redirected_to chats_path
    assert_equal "You are already signed in.", flash[:alert]
  end

  test "#edit: redirects if token is blank" do
    get edit_user_password_path

    assert_redirected_to new_user_session_path
    assert_equal(
      "You can't access this page without coming from a password reset email. If you do come from a password reset email, please make sure you used the full URL provided.",
      flash[:alert]
    )
  end

  test "#update: should update password" do
    user = users(:Ema)
    token = user.send(:set_reset_password_token)

    patch user_password_path, params: {
      user: {
        reset_password_token: token,
        password: "new_password",
        password_confirmation: "new_password"
      }
    }

    assert_redirected_to chats_path
    assert_equal "Your password has been changed successfully. You are now signed in.", flash[:notice]
    assert user.reload.reset_password_token.nil?
  end

  test "#update: redirects if already signed in" do
    user = users(:Walker)
    sign_in user
    token = user.send(:set_reset_password_token)

    patch user_password_path, params: {
      user: {
        reset_password_token: token,
        password: "new_password",
        password_confirmation: "new_password"
      }
    }

    assert_redirected_to chats_path
    assert_equal "You are already signed in.", flash[:alert]
  end

  test "#update: should not allow invalid token" do
    user = users(:Buddy)
    user.send(:set_reset_password_token)

    patch user_password_path, params: {
      user: {
        reset_password_token: "invalid_token",
        password: "new_password",
        password_confirmation: "new_password"
      }
    }

    assert_response :unprocessable_entity
    assert_select "#error_explanation li", "Reset password token is invalid"
  end

  test "#update: should not allow blank token" do
    user = users(:Ema)
    user.send(:set_reset_password_token)

    patch user_password_path, params: {
      user: {
        password: "new_password",
        password_confirmation: "new_password"
      }
    }

    assert_response :unprocessable_entity
    assert_select "#error_explanation li", "Reset password token can't be blank"
  end

  test "#update: should not allow blank password" do
    user = users(:Ema)
    token = user.send(:set_reset_password_token)

    patch user_password_path, params: { user: { reset_password_token: token } }

    assert_response :unprocessable_entity
    assert_select "#error_explanation li", "Password can't be blank"
  end

  test "#update: should not allow mismatched password_confirmation" do
    user = users(:Buddy)
    token = user.send(:set_reset_password_token)

    patch user_password_path, params: {
      user: {
        reset_password_token: token,
        password: "new_password",
        password_confirmation: "new_password123"
      }
    }

    assert_response :unprocessable_entity
    assert_select "#error_explanation li", "Password confirmation doesn't match Password"
  end

  test "#update: password length check" do
    user = users(:Walker)

    # < 6: Invalid
    token = user.send(:set_reset_password_token)
    patch user_password_path, params: {
      user: {
        reset_password_token: token,
        password: "a" * 5,
        password_confirmation: "a" * 5
      }
    }
    assert_response :unprocessable_entity
    assert_select "#error_explanation li", "Password is too short (minimum is 6 characters)"

    # 6: Valid
    token = user.send(:set_reset_password_token)
    patch user_password_path, params: {
      user: {
        reset_password_token: token,
        password: "a" * 6,
        password_confirmation: "a" * 6
      }
    }
    assert_redirected_to chats_path
    assert_equal "Your password has been changed successfully. You are now signed in.", flash[:notice]

    sign_out user

    # 128: Valid
    token = user.send(:set_reset_password_token)
    patch user_password_path, params: {
      user: {
        reset_password_token: token,
        password: "a" * 128,
        password_confirmation: "a" * 128
      }
    }
    assert_redirected_to chats_path
    assert_equal "Your password has been changed successfully. You are now signed in.", flash[:notice]

    sign_out user

    # > 128: Invalid
    token = user.send(:set_reset_password_token)
    patch user_password_path, params: {
      user: {
        reset_password_token: token,
        password: "a" * 129,
        password_confirmation: "a" * 129
      }
    }
    assert_response :unprocessable_entity
    assert_select "#error_explanation li", "Password is too long (maximum is 128 characters)"
  end
end
