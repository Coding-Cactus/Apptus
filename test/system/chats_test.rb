# frozen_string_literal: true

require "application_system_test_case"

class ChatsTest < ApplicationSystemTestCase
  test "full chat flow" do
    using_session :Ema do
      visit root_url

      fill_in "Email", with: "ema_heaney@lakin.test"
      fill_in "Password", with: "F4yAlbgeSS"
      click_on "Log in"

      assert_selector ".flash.notice", text: "Signed in successfully."

      assert_selector "a[href='#{new_chat_path}']"
      click_on "create a new chat"

      assert_selector "label", text: "Name"
      assert_selector "input[name='chat[name]']"
      assert_selector "input[type='submit'][value='Create']"
      fill_in "Name", with: "Test Chat 123"

      assert_selector "a[href='#{pending_contacts_path}']", text: "+ Add new contacts"

      assert_selector "input[type='checkbox'][name='chat[users][]']", count: 3
      find(:css, "#chat_users_#{users(:Ema).contacts.first.id}").set(true)

      click_on "Create"

      assert_selector ".flash.notice", text: "Chat successfully created"

      assert_selector "#list-header.rounded-bottom"
      assert_selector ".chat-preview.selected .chat-preview-header span", text: "Test Chat 123"
      assert_selector ".chat-preview.rounded-top"

      assert_selector ".system-message:nth-child(1) span:nth-child(1)", text: "Chat created"
      assert_selector ".system-message:nth-child(2) span:nth-child(1)", text: "#{users(:Ema).title_name} was added"
      assert_selector ".system-message:nth-child(3) span:nth-child(1)", text: "#{users(:Ema).contacts.first.title_name} was added"

      assert_selector "input[name='message[content]']"
      assert_selector "button[type='submit']"

      fill_in "message[content]", with: "Hello!"
      find(:css, "#new-message button[type='submit']").click
      assert_selector ".message p", text: "Hello!"
    end

    using_session :Kasey do
      visit root_url

      fill_in "Email", with: "shields_kasey@littel.test"
      fill_in "Password", with: "Th7hJl9Plbibloc"
      click_on "Log in"

      find(:css, ".chat-preview:first-of-type a.link-blanket").click

      fill_in "message[content]", with: "Hi there!"
      find(:css, "#new-message button[type='submit']").click
      assert_selector ".message p", text: "Hi there!"
    end

    using_session :Ema do
      assert_selector ".message p", text: "Hi there!"

      find(:css, ".chat-preview.selected .chat-preview-header a").click

      assert_selector "input[name='chat[name]'][value='Test Chat 123']"
      assert_selector "input[type='submit'][value='Update']"
      fill_in "Name", with: "Test Chat 1234"
      click_on "Update"

      assert_selector ".flash.notice", text: "Chat updated"
      assert_selector ".chat-preview.selected .chat-preview-header span", text: "Test Chat 1234"

      assert_selector "#new-member span", text: "Add new members"
      assert_selector "#delete-chat span", text: "Delete Chat"

      assert_selector ".member", count: 2

      assert_selector ".dropdown-select > div span span", text: "Basic"
      find(:css, ".dropdown-select > div").click
      find(:css, ".dropdown-select ul > :last-child").click
      assert_selector ".dropdown-select > div span span", text: "Administrator"
      assert_selector ".flash.notice", text: "Role updated for chat member"

      accept_prompt("Are you sure you want to remove #{users(:Kasey).title_name} from this chat?") do
        find(:css, ".remove").click
      end
      assert_selector ".flash.alert", text: "Cannot have less than 2 people in a chat"

      click_on "Add new members"
      assert_selector "a span", text: "Back"
      assert_selector "a span", text: "Add new contacts"
      assert_selector ".member", count: 2
      assert_selector ".member a", count: 2

      find(:css, ".member:first-of-type a").click
      assert_selector ".flash.notice", text: "New chat member added"

      click_on "Back"

      assert_selector ".member", count: 3
      accept_prompt("Are you sure you want to remove #{users(:Buddy).title_name} from this chat?") do
        find(:css, ".member:first-of-type .remove").click
      end
      assert_selector ".flash.notice", text: "Chat member removed"

      accept_prompt("Are you sure you want to permanently delete this chat and all of it's messages?") do
        click_on "Delete Chat"
      end
      assert_selector "h2", text: "Welcome to Apptus"

      assert_no_selector ".chat-preview .chat-preview-header span", text: "Test Chat 1234"
      assert_no_selector ".chat-preview.selected"
      assert_no_selector ".chat-preview.rounded-top"
      assert_no_selector ".chat-preview.rounded-bottom"
    end
  end
end
