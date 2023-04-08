# frozen_string_literal: true
class ChatsController < ApplicationController
  layout 'chat'

  before_action :authenticate_user!
  before_action :load_chat, only: :show
  before_action :load_chats, except: :destroy
  before_action :can_view_chat?, only: %i[show update destroy]
  before_action :handle_selection, except: :destroy
  def index; end

  def show
    @message_groups = @chat.messages.includes(:user, :statuses).limit(20).order(created_at: :asc)
                           .reduce([]) do |groups, msg|
                             if groups == [] || groups[-1][-1].user_id != current_user.id
                               groups += [[msg]]
                             else
                               groups[-1] += [msg]
                             end
                             groups
                           end
  end

  def new
    @chat = Chat.new
    @contacts = contacts
  end

  def create
    @chat = Chat.new(name: new_chat_params[:name])

    @chat.add_users([current_user.id] + new_chat_params[:users].to_a)

    if @chat.save
      flash[:notice] = 'Chat successfully created'
      redirect_to @chat
    else
      @contacts = contacts
      render :new, status: :unprocessable_entity
    end
  end

  def destroy; end

  private

  def contacts
    current_user.contacts.includes(:creator, :target)
                .map { |c| c.target_id == current_user.id ? c.creator : c.target }
                .sort_by(&:title_name)
  end

  def load_chat
    @chat = Chat.find_by(id: params[:id]) || not_found
  end

  def load_chats
    @chats = current_user.chats.includes(:last_message).order('messages.created_at' => :desc)
  end

  def new_chat_params
    params.require(:chat).permit(:name, users: [])
  end

  def can_view_chat?
    not_found unless ChatMember.exists?(user_id: current_user.id, chat_id: params[:id])
  end

  def handle_selection
    @selected = @chat&.id

    ids = @chats.map(&:id)
    index = ids.index(@selected)

    @footer_rounded = ids.last == @selected
    @header_rounded = ids.first == @selected

    return if index.nil?

    @rounded_top    = ids[index + 1]
    @rounded_bottom = ids[index - 1] if index - 1 >= 0
  end
end
