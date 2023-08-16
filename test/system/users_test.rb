# frozen_string_literal: true

require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test "new user flow" do
    visit root_url

    assert_selector "h2", text: "Apptus"
    assert_selector "a[href='#{new_user_registration_path}']", text: "Register"
    assert_selector "a[href='#{new_user_password_path}']", text: "Forgot your password?"
    assert_selector "a[href='#{new_user_confirmation_path}']", text: "Didn't receive confirmation instructions?"

    click_on "Register"

    assert_selector "label", text: "Email"
    assert_selector "input[name='user[email]']"

    assert_selector "label", text: "Name"
    assert_selector "input[name='user[name]']"

    assert_selector "label", text: "Password"
    assert_selector "input[name='user[password]']"

    assert_selector "label", text: "Password Confirmation"
    assert_selector "input[name='user[password_confirmation]']"

    assert_selector "input[type='submit'][value='Register']"

    fill_in "Email", with: "testing@example.com"
    fill_in "Name", with: "Test User"
    fill_in "Password", with: "password"
    fill_in "Password Confirmation", with: "password"

    click_on "Register"

    assert_selector(
      ".flash.notice",
      text: "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
    )

    visit user_confirmation_path(confirmation_token: User.find_by(email: "testing@example.com").confirmation_token)

    assert_selector(
      ".flash.notice",
      text: "Your email address has been successfully confirmed."
    )

    assert_selector "label", text: "Email"
    assert_selector "input[name='user[email]']"

    assert_selector "label", text: "Password"
    assert_selector "input[name='user[password]']"

    assert_selector "label", text: "Remember me"
    assert_selector "input[name='user[remember_me]']"

    assert_selector "input[type='submit'][value='Log in']"

    fill_in "Email", with: "testing@example.com"
    fill_in "Password", with: "password"

    click_on "Log in"

    assert_selector "h2", text: "Welcome to Apptus"
    assert_selector(
      ".flash.notice",
      text: "Signed in successfully."
    )
  end
end
