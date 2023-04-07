class Message < ApplicationRecord
  belongs_to :chat
  belongs_to :user

  has_many :statuses

  validates :content, presence: true, length: { maximum: 2500 }

  def lowest_status
    statuses.reduce('read') do |lowest, status|
      order = %w[read received]
      order.index(status.status) < order.index(lowest) ? status.status : lowest
    end
  end
end
