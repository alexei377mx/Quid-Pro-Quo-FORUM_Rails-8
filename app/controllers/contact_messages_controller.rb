class ContactMessagesController < ApplicationController
  before_action :set_contact_message, only: :show
  before_action -> { authorize! :read, @contact_message }, only: :show

  def new
    @contact_message = ContactMessage.new
  end

  def create
    @contact_message = ContactMessage.new(contact_message_params)
    if @contact_message.save
      redirect_to root_path, notice: t("contact_messages.controller.success")
    else
      Rails.logger.error(t("contact_messages.controller.error_log", errors: @contact_message.errors.full_messages.join(", ")))
      flash[:alert] = t("contact_messages.controller.failure")
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  private

  def set_contact_message
    @contact_message = ContactMessage.find(params[:id])
  end

  def contact_message_params
    params.require(:contact_message).permit(:name, :email, :subject, :message)
  end
end
