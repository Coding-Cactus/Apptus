# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'system account exists' do
    assert User.where(role: 'system').length == 1
  end

  test 'valid new user' do
    user = User.new(
      name: 'Test Account',
      email: 'user@example.com',
      password: 'password',
      password_confirmation: 'password'
    )

    assert user.valid?
  end

  test 'should not accept user with no name' do
    user = User.new(
      email: 'no-name@example.com',
      password: 'password',
      password_confirmation: 'password'
    )

    refute user.valid?
  end

  test 'name length check' do
    # < 2: Invalid
    refute User.new(
      name: 'a',
      email: 'no-name@example.com',
      password: 'password',
      password_confirmation: 'password'
    ).valid?

    # 2: Valid
    assert User.new(
      name: 'ab',
      email: 'no-name@example.com',
      password: 'password',
      password_confirmation: 'password'
    ).valid?

    # > 255: Invalid
    refute User.new(
      name: 'a' * 256,
      email: 'no-name@example.com',
      password: 'password',
      password_confirmation: 'password'
    ).valid?

    # 255: Valid
    assert User.new(
      name: 'a' * 255,
      email: 'no-name@example.com',
      password: 'password',
      password_confirmation: 'password'
    ).valid?
  end

  test 'should not accept user with no email' do
    user = User.new(
      name: 'No Email',
      password: 'password',
      password_confirmation: 'password'
    )

    refute user.valid?
  end

  test 'should not accept user with invalid email' do
    user = User.new(
      name: 'No Password Confirmation',
      email: 'abc',
      password: 'password',
      password_confirmation: 'password'
    )

    refute user.valid?
  end

  test 'should not accept user with duplicate email' do
    User.create(
      name: 'Duplicate Email',
      email: 'duplicate@example.com',
      password: 'password',
      password_confirmation: 'password'
    )

    user = User.new(
      name: 'Duplicate Email',
      email: 'duplicate@example.com',
      password: 'password',
      password_confirmation: 'password'
    )

    refute user.valid?
  end

  test 'should not accept user with no password' do
    user = User.new(
      name: 'No Password',
      email: 'no-password@example.com'
    )

    refute user.valid?
  end

  test 'should not accept user with mismatched password confirmation' do
    user = User.new(
      name: 'Mismatched Password Confirmation',
      email: 'wrong-pw-confirm@example.com',
      password: 'password',
      password_confirmation: 'wrong-password'
    )

    refute user.valid?
  end

  test 'password length check' do
    # < 6: Invalid
    refute User.new(
      name: 'Short Password',
      email: 'short-pw@example.com',
      password: '12345',
      password_confirmation: '12345'
    ).valid?

    # 6: Valid
    assert User.new(
      name: '6 char pw',
      email: '6-pw@example.com',
      password: '123456',
      password_confirmation: '123456'
    ).valid?

    # > 128: Invalid
    refute User.new(
      name: 'Long Password',
      email: 'long-pw@example.com',
      password: 'a' * 129,
      password_confirmation: 'a' * 129
    ).valid?

    # 128: Valid
    assert User.new(
      name: '128 char pw',
      email: '128-pw@example.com',
      password: 'a' * 128,
      password_confirmation: 'a' * 128
    ).valid?
  end

  test 'should assign colour to newly created user' do
    user = User.create(
      name: 'Test Colour',
      email: 'colour@example.com',
      password: 'password',
      password_confirmation: 'password'
    )

    refute user.colour.nil?
  end

  test 'colour should be in 6 digit hex format' do
    user = User.create(
      name: 'Test Colour',
      email: '6-hex@example.com',
      password: 'password',
      password_confirmation: 'password'
    )

    assert user.colour.match?(/#[A-F0-9]{6}/)
  end

  test 'should assign contact number to newly created user' do
    user = User.create(
      name: 'Test Contact Number',
      email: 'contact-num@example.com',
      password: 'password',
      password_confirmation: 'password'
    )

    refute user.contact_number.nil?
  end

  test 'should send confirmation email to newly created user' do
    user = User.new(
      name: 'Test Confirmation Email',
      email: 'test-confirm@example.com',
      password: 'password',
      password_confirmation: 'password'
    )

    assert_emails(1) { user.save }

    email = Devise::Mailer.deliveries.last

    assert_equal [user.email], email.to
    assert_equal 'Confirmation instructions', email.subject
    assert email.body.include?(user_confirmation_path(confirmation_token: user.confirmation_token))
  end

  test 'contact number should be 12 numbers' do
    user = User.create(
      name: 'Test Contact Number',
      email: 'contact-num-format@example.com',
      password: 'password',
      password_confirmation: 'password'
    )

    assert user.contact_number.match?(/\d{12}/)
  end

  test 'User#title_name' do
    assert_equal 'Roman Dubuque', users(:Roman).title_name
    assert_equal 'Stevie Casper', users(:Stevie).title_name
    assert_equal 'Corrie Parker', users(:Corrie).title_name
    assert_equal 'Stanton Bob Kulas', users(:Stanton).title_name
  end

  test 'User#first_name' do
    assert_equal 'Roman', users(:Roman).first_name
    assert_equal 'Stevie', users(:Stevie).first_name
    assert_equal 'Corrie', users(:Corrie).first_name
    assert_equal 'Stanton', users(:Stanton).first_name
  end

  test 'User#Initials' do
    assert_equal 'RD', users(:Roman).initials
    assert_equal 'SC', users(:Stevie).initials
    assert_equal 'CP', users(:Corrie).initials
    assert_equal 'SB', users(:Stanton).initials
  end

  test 'User#nice_contact_number' do
    roman = users(:Roman)
    assert roman.nice_contact_number.match?(/\d{4}-\d{4}-\d{4}/)
    assert_equal roman.contact_number, roman.nice_contact_number.gsub('-', '')

    stevie = users(:Stevie)
    assert stevie.nice_contact_number.match?(/\d{4}-\d{4}-\d{4}/)
    assert_equal stevie.contact_number, stevie.nice_contact_number.gsub('-', '')
  end

  test 'User#incoming_contact_requests' do
    reqs = users(:Stanton).incoming_contact_requests

    assert_equal 2, reqs.length
    assert_equal users(:Corrie), reqs.first
    assert_equal users(:Earlie), reqs.last

    assert_equal 0, users(:Corrie).incoming_contact_requests.length
  end

  test 'User#outgoing_contact_requests' do
    reqs = users(:Stanton).outgoing_contact_requests

    assert_equal 1, reqs.length
    assert_equal users(:Stevie), reqs.first

    assert_equal 0, users(:Roman).outgoing_contact_requests.length
  end

  test 'User#contacts' do
    contacts = users(:Stanton).contacts

    assert_equal 1, contacts.length
    assert_equal users(:Roman), contacts.first

    assert_equal 0, users(:Stevie).contacts.length
  end

  test 'User#find_contact' do
    assert_equal contacts(:'Stanton<->Roman'), users(:Stanton).find_contact(users(:Roman).id)
    assert_equal contacts(:'Stanton->Stevie'), users(:Stevie).find_contact(users(:Stanton).id)
    assert_nil users(:Roman).find_contact(users(:Earlie).id)
  end

  test 'messages destroyed after user destroy' do
    user = users(:Stanton)
    message_ids = user.messages.ids

    assert_equal 3, user.messages.length

    user.destroy

    assert_equal 0, Message.where(id: message_ids).length
  end

  test 'chat_members destroyed after user destroy' do
    user = users(:Stanton)
    chat_member_ids = user.chat_members.ids

    assert_equal 2, user.chat_members.length

    user.destroy

    assert_equal 0, ChatMember.where(id: chat_member_ids).length
  end

  test 'contacts destroyed after user destroy' do
    user = users(:Roman)
    contact_ids = Contact.where(creator_id: user.id).ids.concat(Contact.where(target_id: user.id).ids)

    assert_equal 3, contact_ids.length

    user.destroy

    assert_equal 0, Contact.where(id: contact_ids).length
  end
end
