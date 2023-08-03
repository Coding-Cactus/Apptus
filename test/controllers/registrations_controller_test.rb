# frozen_string_literal: true

require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "#new" do
    get new_user_registration_path

    assert_response :success

    assert_select "input[name='user[email]']"
    assert_select "input[name='user[name]']"
    assert_select "input[name='user[password]']"
    assert_select "input[name='user[password_confirmation]']"
    assert_select "input[type='submit']"
  end

  test "#create: valid new user, and test email is sent" do
    email = "bob.cactus@example.com"
    name = "bob Cactus"
    password = "cactus123"
    password_confirmation = "cactus123"

    post account_path, params: { user: { email:, name:, password:, password_confirmation: } }

    assert_redirected_to root_path
    assert_equal(
      "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.",
      flash[:notice]
    )

    user = User.find_by(email:)

    assert_not user.nil?
    assert_equal name, user.name
    assert_not user.colour.nil?
    assert_not user.encrypted_password.nil?

    email = Devise::Mailer.deliveries.last

    assert_equal [user.email], email.to
    assert_equal "Confirmation instructions", email.subject
    assert email.body.include?(user_confirmation_path(confirmation_token: user.confirmation_token))
  end

  test "#create: should not accept user with no email" do
    post account_path, params: { user: { name: "bob", password: "cactus123", password_confirmation: "cactus123" } }

    assert_response :unprocessable_entity
  end

  test "#create: should not accept user with invalid email" do
    post account_path, params: { user: { email: "bob", name: "bob", password: "cactus123", password_confirmation: "cactus123" } }

    assert_response :unprocessable_entity
  end

  test "#create: should not accept duplicate email" do
    post account_path, params: { user: { email: "same.email@example.com", name: "Fred Phillip", password: "cactus123", password_confirmation: "cactus123" } }
    assert_redirected_to root_path


    post account_path, params: { user: { email: "same.email@example.com", name: "Phillip Fred", password: "cactus321", password_confirmation: "cactus321" } }
    assert_response :unprocessable_entity
  end

  test "#create: should not accept user with no name" do
    post account_path, params: { user: { email: "ihavenoname@example.com", password: "cactus123", password_confirmation: "cactus123" } }

    assert_response :unprocessable_entity
  end

  test "#create: name length check" do
    # < 2: Invalid
    post account_path, params: { user: { email: "1charname@example.com", name: "b", password: "cactus123", password_confirmation: "cactus123" } }
    assert_response :unprocessable_entity

    # 2: Valid
    post account_path, params: { user: { email: "2charname@example.com", name: "b" * 2, password: "cactus123", password_confirmation: "cactus123" } }
    assert_redirected_to root_path

    # 255: Valid
    post account_path, params: { user: { email: "255charname@example.com", name: "b" * 255, password: "cactus123", password_confirmation: "cactus123" } }
    assert_redirected_to root_path

    # > 255: Invalid
    post account_path, params: { user: { email: "256charname@example.com", name: "b" * 256, password: "cactus123", password_confirmation: "cactus123" } }
    assert_response :unprocessable_entity
  end

  test "#create: should not accept user with no password" do
    post account_path, params: { user: { email: "bob.nopaswword@example.com", name: "bob cactus" } }

    assert_response :unprocessable_entity
  end

  test "#create: should not accept user with mismatched password confirmation" do
    post account_path, params: { user: { email: "bob.badmatch@example.com", name: "Bob Cactus", password: "cactus123", password_confirmation: "cactus321" } }

    assert_response :unprocessable_entity
  end

  test "#create: password length check" do
    # < 6: Invalid
    password = "c" * 5
    post account_path, params: { user: { email: "5charpass@example.com", name: "Bob Cactus", password:, password_confirmation: password } }
    assert_response :unprocessable_entity

    # 6: Valid
    password = "c" * 6
    post account_path, params: { user: { email: "6charpass@example.com", name: "Bob Cactus", password:, password_confirmation: password } }
    assert_redirected_to root_path

    # 128: Valid
    password = "c" * 128
    post account_path, params: { user: { email: "128charpass@example.com", name: "Bob Cactus", password:, password_confirmation: password } }
    assert_redirected_to root_path

    # > 128: Invalid
    password = "c" * 129
    post account_path, params: { user: { email: "129charpass@example.com", name: "Bob Cactus", password:, password_confirmation: password } }
    assert_response :unprocessable_entity
  end

  test "#edit: should redirect if not logged in" do
    get user_root_path

    assert_redirected_to new_user_session_path
  end

  test "#edit: should show edit form if logged in" do
    sign_in users(:Kasey)

    get user_root_path

    assert_response :success

    assert_select "input[name='user[email]']"
    assert_select "input[name='user[name]']"
    assert_select "input[name='user[password]']"
    assert_select "input[name='user[password_confirmation]']"
    assert_select "input[name='user[current_password]']"
    assert_select "input[type='submit']"
  end

  test "#update: should redirect if not logged in" do
    patch account_path, params: { user: { name: "Ema Anna Heaney", current_password: "F4yAlbgeSS" } }

    assert_redirected_to new_user_session_path
  end

  test "#update: should correctly change email" do
    user = users(:Ema)
    sign_in user

    new_email = "ema_anna_heaney@lakin.test"

    patch account_path, params: { user: { email: new_email, current_password: "F4yAlbgeSS" } }

    assert_redirected_to account_path
    assert_equal new_email, user.reload.email
    assert_equal "Your account has been updated successfully.", flash[:notice]
  end

  test "#update should not accept duplicate email" do
    sign_in users(:Walker)

    patch account_path, params: { user: { email: "buddy.balistreri@donnelly.example", password_confirmation: "gIc4jjHjMJBWtROm" } }
    assert_response :unprocessable_entity
  end

  test "#update: should not accept invalid email" do
    sign_in users(:Ema)

    patch account_path, params: { user: { email: "ema_heaney", current_password: "F4yAlbgeSS" } }
    assert_response :unprocessable_entity
  end

  test "#update: should correctly change name" do
    user = users(:Ema)
    sign_in user

    new_name = "Ema Anna Heaney"

    patch account_path, params: { user: { name: new_name, current_password: "F4yAlbgeSS" } }

    assert_redirected_to account_path
    assert_equal new_name, user.reload.name
    assert_equal "Your account has been updated successfully.", flash[:notice]
  end

  test "#update: name length check" do
    sign_in users(:Ema)

    # < 2: Invalid
    patch account_path, params: { user: { name: "e", current_password: "F4yAlbgeSS" } }
    assert_response :unprocessable_entity

    # 2: Valid
    patch account_path, params: { user: { name: "e" * 2, current_password: "F4yAlbgeSS" } }
    assert_redirected_to account_path

    # 255: Valid
    patch account_path, params: { user: { name: "e" * 255, current_password: "F4yAlbgeSS" } }
    assert_redirected_to account_path

    # > 255: Invalid
    patch account_path, params: { user: { name: "e" * 256, current_password: "F4yAlbgeSS" } }
    assert_response :unprocessable_entity
  end

  test "#update: should correctly change password" do
    user = users(:Ema)
    sign_in user

    new_password = "cactus678"

    patch account_path, params: {
      user: {
        password: new_password,
        password_confirmation: new_password,
        current_password: "F4yAlbgeSS"
      }
    }

    assert_redirected_to account_path
    assert user.reload.valid_password?(new_password)
    assert_equal "Your account has been updated successfully.", flash[:notice]
  end

  test "#update: should not update fields with not current password given" do
    sign_in users(:Buddy)

    patch account_path, params: { user: { email: "123buddy.balistreri@donnelly.example" } }
    assert_response :unprocessable_entity

    patch account_path, params: { user: { name: "Buddy Barry Balistreri" } }
    assert_response :unprocessable_entity

    patch account_path, params: { user: { password: "new_password123", password_confirmation: "new_password123" } }
    assert_response :unprocessable_entity
  end

  test "#update: should not update password with mismatched password confirmation" do
    sign_in users(:Walker)

    patch account_path, params: { user: { password: "my_password", password_confirmation: "password", current_password: "gIc4jjHjMJBWtROm" } }
    assert_response :unprocessable_entity
  end

  test "#destroy: should redirect if not logged in" do
    delete account_path

    assert_redirected_to new_user_session_path
  end

  test "#destroy: should delete user" do
    user = users(:Ema)
    sign_in user

    assert_difference "User.count", -1 do
      delete account_path
    end

    assert_redirected_to root_path
    assert User.find_by(id: user.id).nil?
  end
end
