class Chat < ApplicationRecord
  has_one :last_message, -> { order(created_at: :desc) }, class_name: 'Message'

  has_many :messages, dependent: :destroy
  has_many :chat_members, dependent: :destroy
  has_many :users, through: :chat_members

  validates :name, presence: true, length: { in: 1..30 }
  validates :colour, allow_blank: true, format: /#[A-F0-9]{6}/
  validates :users, length: { minimum: 2, message: 'must be more than just yourself' }

  after_update_commit do
    users.each do |user|
      broadcast_replace_later_to(
        "user_#{user.id}_chats",
        target: "chat_#{id}",
        partial: 'chats/chat',
        locals: { from_stream: true }
      )
    end
  end

  before_create do
    self.colour = COLOURS.sample
  end

  after_create do
    messages.create(user_id: User.find_by(role: :system).id, content: 'Chat created')
  end

  def initials = name.split.first(2).map { |w| w[0] }.join.upcase

  def add_users(current_user, user_ids)
    members = users.map(&:id)
    contacts = current_user.contacts.map { |c| [c.creator_id, c.target_id] }.flatten.uniq

    user_ids.each { |id| add_user(id, members, contacts) }
  end

  private

  def add_user(id, members, contacts)
    return if members.include?(id) || !contacts.include?(id)

    user = User.find(id)
    users << user unless user.nil?
  end
end
