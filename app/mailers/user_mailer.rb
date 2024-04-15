class UserMailer < ApplicationMailer
  def contact_request
    @target  = params[:target]
    @creator = params[:creator]

    mail(to: @target.email, subject: "New Contact Request")
  end
end
