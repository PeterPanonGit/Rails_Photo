class CallbacksController < Devise::OmniauthCallbacksController
  def facebook
    generic_callback "Facebook"
  end

  def twitter
    generic_callback "Twitter"
  end

  def google_oauth2
  	generic_callback "Google"
  end

  def generic_callback kind
      @client = Client.from_omniauth(request.env["omniauth.auth"])

      if @client.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => kind
        @client.daily_reward
        sign_in_and_redirect @client, :event => :authentication
      else
        redirect_to new_client_registration_url, alert: @client.errors.full_messages.join("\n")
      end
  end
end