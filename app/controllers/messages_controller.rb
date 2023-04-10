class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_chat, only: :create
  before_action :can_view_chat?, only: :create

  def create
    @message = @chat.messages.create(user_id: current_user.id, **new_message_params)

    if @message.save
      respond_to do |f|
        f.html { redirect_to @chat, notice: 'Message sent successfully' }
        f.turbo_stream
      end
    else
      flash[:alert] = 'There were problems sending your message'
      redirect_to @chat, status: :unprocessable_entity
    end
  end

  private

  def new_message_params
    params.require(:message).permit(:content)
  end

  def load_chat
    @chat = Chat.find_by(id: params[:chat_id]) || not_found
  end

  def can_view_chat?
    not_found unless ChatMember.exists?(user_id: current_user.id, chat_id: params[:chat_id])
  end
end
