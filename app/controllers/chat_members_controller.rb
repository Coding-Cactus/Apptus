# frozen_string_literal: true

class ChatMembersController < ApplicationController
  layout "chat"

  before_action :authenticate_user!

  before_action :load_chats, only: :new, unless: :turbo_frame_request?
  before_action :populate_chat
  before_action :populate_chat_member, except: %i[new create]
  before_action :populate_contacts, only: :new
  before_action :owner?, only: :update
  before_action :admin_or_owner?, only: %i[new create]
  before_action :higher_permissions?, only: %i[destroy]

  def new; end

  def create
    member = @chat.add_new_member(current_user, params[:user_id].to_i)

    if member
      flash[:notice] = "New chat member added"
      redirect_to new_chat_chat_member_path(@chat)
    else
      load_chats
      populate_contacts

      flash.now[:alert] = "Something went wrong when adding that user to the chat"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @member.update(update_params)
      flash[:notice] = "Role updated for chat member"
    else
      flash[:alert] = "Something went wrong while updating that member's role"
    end

    redirect_to edit_chat_path(@chat)
  end

  def destroy
    if @chat.chat_members.count > 2
      @member.destroy
      flash[:notice] = "Chat member removed"
    else
      flash[:alert] = "Cannot have less than 2 people in a chat"
    end

    redirect_to edit_chat_path(@chat)
  end

  private
    def update_params
      params.require(:chat_member).permit(:role)
    end

    def load_chats
      @chats = current_user.chats.includes(:last_message).order("messages.created_at" => :desc)
    end

    def populate_chat
      @chat = Chat.find_by(id: params[:chat_id]) || not_found
    end

    def populate_chat_member
      @member = ChatMember.find(params[:id]) || not_found
    end

    def populate_contacts
      @contacts = current_user.contacts.where.not(id: @chat.users).order("LOWER(users.name)")
    end

    def owner?
      not_found unless @chat.owner_id == current_user.id
    end

    def admin_or_owner?
      not_found unless @chat.owner_id == current_user.id || @chat.administrators.include?(current_user)
    end

    def higher_permissions?
      unless @chat.owner_id == current_user.id || (
        @chat.administrator_ids.include?(current_user.id) &&
          !@chat.administrator_ids.include?(@member.user_id) &&
          @member.user_id != @chat.owner_id
      )
        not_found
      end
    end
end
