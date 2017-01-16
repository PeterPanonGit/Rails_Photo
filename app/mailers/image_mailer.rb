class ImageMailer < ApplicationMailer
  default from:  "photopaint.us@gmail.com"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.image_mailer.send_image.subject
  #
  def send_image(user, iter, max_iter, file)
      attachments['out.png'] = file
      mail(to: user.email, subject: "Your image has been rendered")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.image_mailer.send_error.subject
  #
  def send_error(email, message, queue,file)
    #@errors = message
    attachments['error.txt'] = file
    mail(to: email, subject: 'PhotoPaint ERROR')
  end


  def get_default_email
    file = Rails.root.join('config/config.secret')
    get_param_config(file, :smtp_settings, :user_name)
  end
end
