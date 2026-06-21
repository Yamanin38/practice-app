# app/controllers/contacts_controller.rb
class ContactsController < ApplicationController
  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      text = "📩 スローンズチームサイトよりお問い合わせがありました\n\n" \
             "【お名前】#{@contact.name}\n" \
             "【メール】#{@contact.email}\n" \
             "【件名】#{@contact.subject}\n" \
             "【メッセージ】\n#{@contact.message}"

      LineNotificationJob.perform_later(text)

      redirect_to contact_path
    else
      flash.now[:alert] = "入力内容にエラーがあります。"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :subject, :message)
  end
end