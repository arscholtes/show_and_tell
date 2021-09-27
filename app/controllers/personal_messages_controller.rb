# Language: Ruby, Level: Level 4
class PersonalMessagesController < ApplicationController
  before_action :find_conversation! # Need logic for when you send the message, right now we only have logic for when we load the message.

  def create
    @personal_message = current_user.personal_messages.build(personal_message_params)
    @personal_message.conversation_id = conversation_id
    @personal_message.save!

    flash[:success] = "Your message was sent!"
    redirect_to conversation_path(@conversation)
  end

  def new
    @personal_message = current_user.personal_messages.build
  end

  private

  def personal_message_params
    @conversation = Conversation.find_by(id: params[:conversation_id])
    redirect_to(root_path) and return unless @conversation && @conversation.participates?(current_user)
  end
end
