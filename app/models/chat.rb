class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :chat_members
  has_many :users, through: :chat_members

  validates :name, presence: true, length: { between: 1..30 }
  validates :colour, allow_blank: true, format: /#[A-F0-9]{6}/

  before_create do
    self.colour = COLOURS.sample
  end
end
