# frozen_string_literal: true

require "application_system_test_case"

class ContactsTest < ApplicationSystemTestCase
  test "new contact flow" do
    using_session :Buddy do
      visit root_url

      fill_in "Email", with: "buddy.balistreri@donnelly.example"
      fill_in "Password", with: "nV4hJLD9n2fbljf"
      click_on "Log in"
      assert_selector ".flash.notice", text: "Signed in successfully."

      assert_selector "a[href='#{contacts_path}']"
      find(:css, "a[href='#{contacts_path}']").click

      assert_selector "nav strong", text: "Contacts"
      assert_selector ".contact", count: 3
      assert_selector "label", text: "Your Contact Number"
      assert_selector "input[value='3038-6155-7744']"
      assert_selector "button", text: "Copy"

      assert_selector "nav a", text: "Pending"
      click_on "Pending"

      assert_selector "nav strong", text: "Pending"
      assert_selector "label", text: "Add Contact"
      assert_selector "input[name='contact[contact_number]']"
      assert_selector "input[type='submit'][value='Add']"

      fill_in "contact[contact_number]", with: "0213-5377-4705"
      click_on "Add"

      assert_selector ".flash.notice", text: "Contact request sent successfully"
      assert_selector "h3", text: "Outgoing Requests"
      assert_selector ".contact", count: 1
      assert_selector ".contact div span", text: "Stevie Casper"
      assert_selector "a.reject"

      fill_in "contact[contact_number]", with: "0289-1628-5180"
      click_on "Add"
      assert_selector ".contact", count: 2
      assert_selector ".contact:first-of-type div span", text: "Corrie Parker"
    end

    using_session :Stanton do
      visit root_url

      fill_in "Email", with: "kulas_stanton@gulgowski.test"
      fill_in "Password", with: "Kf2wP2fu4Fl"
      click_on "Log in"

      find(:css, "a[href='#{contacts_path}']").click
      click_on "Pending"

      fill_in "contact[contact_number]", with: "3038-6155-7744"
      click_on "Add"
    end

    using_session :Buddy do
      page.driver.browser.navigate.refresh

      assert_selector ".contact", count: 3
      assert_selector ".contact:first-of-type div span", text: "Stanton Bob Kulas"

      find(:css, "a.accept").click

      assert_selector ".flash.notice", text: "Contact request accepted"
      assert_selector ".contact", count: 2
    end

    using_session :Stanton do
      page.driver.browser.navigate.refresh

      assert_selector ".contact", count: 3

      find(:css, "nav > a").click
      assert_selector ".contact", count: 2
    end

    using_session :Buddy do
      find(:css, ".contact:first-of-type a.reject").click
      assert_selector ".flash.alert", text: "Contact request denied"
      assert_selector ".contact", count: 1
    end

    using_session :Stevie do
      visit root_url

      fill_in "Email", with: "stevie_casper@hand-kilback.test"
      fill_in "Password", with: "oUTdhY6W8"
      click_on "Log in"

      find(:css, "a[href='#{contacts_path}']").click
      click_on "Pending"

      find(:css, ".contact:first-of-type a.accept").click

      assert_selector ".flash.notice", text: "Contact request accepted"
      assert_selector ".contact", count: 1
    end

    using_session :Buddy do
      page.driver.browser.navigate.refresh

      assert_selector ".contact", count: 0

      find(:css, "nav > a").click
      assert_selector ".contact", count: 5
    end
  end
end
