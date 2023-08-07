# frozen_string_literal: true

require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  test "#index: should redirect if not logged in" do
    get contacts_path
    assert_redirected_to new_user_session_path
  end

  test "#index: should get index when logged in" do
    user = users(:Buddy)
    sign_in user

    get contacts_path

    assert_response :success
    assert_select "#contacts-list .contact", 3
    assert_select "a[href='#{pending_contacts_path}']"
    assert_select "input#contact-number[value='#{user.nice_contact_number}']"
  end

  test "#new: should redirect if not logged in" do
    get pending_contacts_path
    assert_redirected_to new_user_session_path
  end

  test "#new: should get new when logged in" do
    sign_in users(:Stanton)

    get pending_contacts_path

    assert_response :success
    assert_select "input[name='contact[contact_number]']"
    assert_select "input[type='submit']"
    assert_select "a.accept", 2
    assert_select "a.reject", 3
  end

  test "#create: should redirect if not logged in" do
    post contacts_path, params: { contact: { contact_number: users(:Buddy).nice_contact_number } }
    assert_redirected_to new_user_session_path
  end

  test "#create: should create a contact request when logged in" do
    sign_in users(:Stanton)

    assert_difference "Contact.count", 1 do
      post contacts_path, params: { contact: { contact_number: users(:Buddy).nice_contact_number } }
    end

    assert_redirected_to pending_contacts_path
    assert_equal "Contact request sent successfully", flash[:notice]

    contact = Contact.last
    assert_equal users(:Stanton).id, contact.creator_id
    assert_equal users(:Buddy).id, contact.target_id
    assert_equal "pending", contact.status
  end

  test "#create: should not create a contact request if the contact number is blank" do
    sign_in users(:Roman)

    assert_no_difference "Contact.count" do
      post contacts_path, params: { contact: { contact_number: "" } }
    end

    assert_redirected_to pending_contacts_path
    assert_equal "Couldn't find a user with that contact number", flash[:alert]
  end

  test "#create: should not create a contact request if the contact number belongs to no users" do
    sign_in users(:Ema)

    assert_no_difference "Contact.count" do
      post contacts_path, params: { contact: { contact_number: "1234-5678-9012" } }
    end

    assert_redirected_to pending_contacts_path
    assert_equal "Couldn't find a user with that contact number", flash[:alert]
  end

  test "#create: should not create a contact request if the contact number is invalid" do
    sign_in users(:Roman)

    assert_no_difference "Contact.count" do
      post contacts_path, params: { contact: { contact_number: "123" } }
    end

    assert_redirected_to pending_contacts_path
    assert_equal "Couldn't find a user with that contact number", flash[:alert]
  end

  test "#create: should not create a contact request if the contact number is the current user's" do
    sign_in users(:Ema)

    assert_no_difference "Contact.count" do
      post contacts_path, params: { contact: { contact_number: users(:Ema).nice_contact_number } }
    end

    assert_redirected_to pending_contacts_path
    assert_equal "Couldn't find a user with that contact number", flash[:alert]
  end

  test "#create: should not create a contact request if the user is already a contact" do
    sign_in users(:Kasey)

    assert_no_difference "Contact.count" do
      post contacts_path, params: { contact: { contact_number: users(:Ema).nice_contact_number } }
    end

    assert_redirected_to pending_contacts_path
    assert_equal "Couldn't find a user with that contact number", flash[:alert]
  end

  test "#create: should not create a contact request if the user is already a pending contact request" do
    sign_in users(:Earlie)

    assert_no_difference "Contact.count" do
      post contacts_path, params: { contact: { contact_number: users(:Stanton).nice_contact_number } }
    end

    assert_redirected_to pending_contacts_path
    assert_equal "Couldn't find a user with that contact number", flash[:alert]


    sign_in users(:Stanton)

    assert_no_difference "Contact.count" do
      post contacts_path, params: { contact: { contact_number: users(:Earlie).nice_contact_number } }
    end

    assert_redirected_to pending_contacts_path
    assert_equal "Couldn't find a user with that contact number", flash[:alert]
  end

  test "#update: should redirect if not logged in" do
    patch contact_path(users(:Stanton))
    assert_redirected_to new_user_session_path
  end

  test "#update: should accept contact request if current user is target" do
    sign_in users(:Stanton)

    patch contact_path(users(:Earlie))

    assert_redirected_to pending_contacts_path
    assert_equal "Contact request accepted", flash[:notice]

    contact = Contact.find_by(creator: users(:Earlie), target: users(:Stanton))
    assert_equal "accepted", contact.status
  end

  test "#update: should not allow contact request to be accepted if current user is creator" do
    sign_in users(:Stanton)

    assert_raise ActionController::RoutingError do
      patch contact_path(users(:Stanton))
    end
  end

  test "#update: should not allow contact request to be accepted if contact request does not exist" do
    sign_in users(:Stanton)

    assert_raise ActionController::RoutingError do
      patch contact_path(users(:Buddy))
    end
  end

  test "#destroy: should redirect if not logged in" do
    delete contact_path(users(:Buddy))
    assert_redirected_to new_user_session_path
  end

  test "#destroy: should reject contact request if current user is target" do
    sign_in users(:Stanton)

    delete contact_path(users(:Corrie))

    assert_redirected_to pending_contacts_path
    assert_equal "Contact request denied", flash[:alert]

    assert_nil Contact.find_by(creator: users(:Corrie), target: users(:Stanton))
  end

  test "#destroy: should cancel contact request if current user is creator" do
    sign_in users(:Corrie)

    delete contact_path(users(:Stanton))

    assert_redirected_to pending_contacts_path
    assert_equal "Contact request denied", flash[:alert]

    assert_nil Contact.find_by(creator: users(:Corrie), target: users(:Stanton))
  end

  test "#destory: should 404 if contact request does not exist" do
    sign_in users(:Stanton)

    assert_raise ActionController::RoutingError do
      delete contact_path(users(:Buddy))
    end
  end

  test "#destroy: should 404 if request has already been accepted" do
    sign_in users(:Walker)

    assert_raise ActionController::RoutingError do
      delete contact_path(users(:Ema))
    end
  end
end
