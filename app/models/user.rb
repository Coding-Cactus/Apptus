class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  validates :name, presence: true, length: { in: 2..255 }
  validates :colour, allow_blank: true, format: /#[A-F0-9]{6}/

  before_create do
    self.colour = %w[#3D9DD2 #6046FC #74CD55 #D69637 #2CAEA6 #DB43C3 #EF3E3E #37BC74].sample
  end

  def first_name = name.split.first
end
