require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test 'valid contact' do
    stevie = users(:Stevie)
    roman = users(:Roman)

    contact = Contact.new(creator: stevie, target: roman)

    assert contact.save
    assert contact.pending?

    assert stevie.outgoing_contact_requests.include?(roman)
    assert roman.incoming_contact_requests.include?(stevie)

    contact.update(status: :accepted)

    assert contact.accepted?

    assert stevie.contacts.include?(roman)
    assert roman.contacts.include?(stevie)
  end

  test 'should not allow contact with no target' do
    contact = Contact.new(creator: users(:Stevie))

    refute contact.valid?
  end

  test 'should not allow contact with no creator' do
    contact = Contact.new(target: users(:Stevie))

    refute contact.valid?
  end

  test 'should not allow contact with invalid status' do
    assert_raise(ArgumentError) { Contact.new(creator: users(:Earlie), target: users(:Corrie), status: :abcdefg) }
  end
end
