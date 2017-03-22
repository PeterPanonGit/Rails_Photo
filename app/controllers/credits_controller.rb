class CreditsController < ApplicationController

  def pundit_user
    current_client
  end

  def add
    authorize :credit, :add?
    current_client.increment! :credits, 1

    respond_to do |format|
      format.js
    end
  end

end
