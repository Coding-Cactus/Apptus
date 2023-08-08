# frozen_string_literal: true

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test "#new" do
    get new_user_confirmation_path

    assert_response :success

    assert_select "input[name='user[email]']"
    assert_select "input[type='submit']"
  end

  test "#create: should send email" do
    user = users(:Kennith)

    post confirm_email_path, params: { user: { email: user.email } }

    assert_redirected_to new_user_session_path
    assert_equal(
      "You will receive an email with instructions for how to confirm your email address in a few minutes.",
      flash[:notice]
    )

    assert_not user.reload.confirmation_token.nil?

    email = Devise::Mailer.deliveries.last

    assert_equal [user.email], email.to
    assert_equal "Confirmation instructions", email.subject
    assert email.body.include?(user_confirmation_path(confirmation_token: user.confirmation_token))
  end

  test "#create: should not send email for already confirmed emails" do
    user = users(:Buddy)

    post confirm_email_path, params: { user: { email: user.email } }

    assert_response :unprocessable_entity
  end

  test "#create: should not send email for non-existing emails" do
    post confirm_email_path, params: { user: { email: "abcdefg@hijklmnop.qrstuv" } }

    assert_response :unprocessable_entity
  end

  test "#create: should not send email for blank emails" do
    post confirm_email_path, params: { user: {} }

    assert_response :unprocessable_entity
  end

  test "#create: should not send email for invalid emails" do
    post confirm_email_path, params: { user: { email: "abcdefg" } }

    assert_response :unprocessable_entity
  end

  test "#show: valid" do
    user = users(:Kennith)

    post confirm_email_path, params: { user: { email: user.email } }

    user = user.reload
    assert_not user.confirmed?

    get user_confirmation_path(confirmation_token: user.confirmation_token)

    assert_redirected_to new_user_session_path
    assert_equal "Your email address has been successfully confirmed.", flash[:notice]
    assert user.reload.confirmed?
  end

  test "#show: should not allow invalid confirmation token" do
    user = users(:Kennith)
    post confirm_email_path, params: { user: { email: user.email } }
    assert_not user.confirmed?

    get user_confirmation_path(confirmation_token: "a")

    assert_response :success
    assert_select "#error_explanation li", "Confirmation token is invalid"
    assert_not user.reload.confirmed?
  end

  test "#show: should not allow blank confirmation token" do
    user = users(:Kennith)
    post confirm_email_path, params: { user: { email: user.email } }
    assert_not user.confirmed?

    get user_confirmation_path(confirmation_token: "")

    assert_response :success
    assert_select "#error_explanation li", "Confirmation token can't be blank"
    assert_not user.reload.confirmed?
  end
end
