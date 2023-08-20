# frozen_string_literal: true

class ChatsController < ApplicationController
  layout "chat"

  before_action :authenticate_user!
  before_action :load_chat, only: %i[show edit update destroy destroy_pfp]
  before_action :load_chats, except: :destroy, unless: :turbo_frame_request?
  before_action :can_view_chat?, only: %i[show edit update destroy]
  before_action :owner?, only: %i[destroy destroy_pfp]
  before_action :admin_or_owner?, only: :update
  before_action :handle_selection, except: :destroy, unless: :turbo_frame_request?

  def index; end

  def show
    @show_page = true
    @message = @chat.messages.build
    @message_groups = @chat.messages.includes(:user, :statuses).order(created_at: :desc).limit(50)
                           .reverse.reduce([]) { |groups, msg| group_up_message(groups, msg) }
  end

  def new
    @chat = current_user.owned_chats.build
    @contacts = contacts
  end

  def create
    @chat = current_user.owned_chats.new(name: new_chat_params[:name])

    @chat.add_initial_users(current_user, new_chat_params[:users].to_a.map(&:to_i))

    if @chat.save
      flash[:notice] = "Chat successfully created"
      redirect_to @chat
    else
      @contacts = contacts
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @members = @chat.chat_members.includes(:user).order("LOWER(users.name)").references(:users)
  end

  def update
    if @chat.update(update_chat_params)
      flash[:notice] = "Chat updated"
      redirect_to edit_chat_path(@chat)
    else
      @members = @chat.chat_members.includes(:user)

      flash.now[:alert] = "Something went wrong when updating the chat"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @chat.destroy

    flash[:notice] = "Chat successfully deleted"
    redirect_to root_path
  end

  def destroy_pfp
    @chat.pfp.purge

    flash[:notice] = "Chat picture deleted"
    redirect_to edit_chat_path(@chat)
  end

  private
    def contacts
      current_user.contacts.order("LOWER(name)")
    end

    def load_chat
      @chat = Chat.find_by(id: params[:id]) || not_found
    end

    def load_chats
      @chats = current_user.chats.includes(:last_message).order("messages.created_at" => :desc)
    end

    def new_chat_params
      params.require(:chat).permit(:name, users: [])
    end

  def update_chat_params
      params.require(:chat).permit(:name, :pfp)
  end

    def can_view_chat?
      not_found unless ChatMember.exists?(user_id: current_user.id, chat_id: params[:id])
    end

    def owner?
      not_found unless @chat.owner_id == current_user.id
    end

    def admin_or_owner?
      not_found unless @chat.owner_id == current_user.id || @chat.administrators.include?(current_user)
    end

    def handle_selection
      @selected = @chat&.id

      ids = @chats.map(&:id)
      index = ids.index(@selected)

      @footer_rounded = ids.last == @selected && ids.length > 0
      @header_rounded = ids.first == @selected && ids.length > 0

      return if index.nil?

      @rounded_top    = ids[index + 1]
      @rounded_bottom = ids[index - 1] if index - 1 >= 0
    end

    def group_up_message(groups, msg)
      if groups == [] || groups[-1][-1].user_id != msg.user_id
        groups += [[msg]]
      else
        groups[-1] += [msg]
      end

      groups
    end
end
