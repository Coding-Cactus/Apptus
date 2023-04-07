class Contact < ApplicationRecord
  belongs_to :target,  class_name: 'User'
  belongs_to :creator, class_name: 'User'

  enum status: %i[pending accepted]

  validates :status, inclusion: { in: statuses.keys }
end
