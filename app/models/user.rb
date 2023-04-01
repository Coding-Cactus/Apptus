class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  has_many :statuses
  has_many :messages
  has_many :chat_members
  has_many :chats, through: :chat_members

  validates :name, presence: true, length: { in: 2..255 }
  validates :colour, allow_blank: true, format: /#[A-F0-9]{6}/

  before_create do
    self.colour = COLOURS.sample
  end

  def first_name = name.split.first
end
