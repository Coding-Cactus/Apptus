class Message < ApplicationRecord
  belongs_to :chat
  belongs_to :user

  has_many :statuses

  validates :content, presence: true, length: { max: 2500 }
end
