class CommentsController < ApplicationController
  before_action :define_commentable
  before_action :get_comment, only: [:destroy]
  before_action :set_authorize

  def create
    @comment = @relative.comments.create client: current_client, body: params[:comment][:body]

    respond_to do |format|
      format.html { redirect_to @relative }
      format.js { render @relative.class.name.underscore }
    end
  end

  def pundit_user
    current_client
  end

  private

  def define_commentable
    @relative_class = Object.const_get params[:comment][:commentable_type]
    @relative = @relative_class.find params[:comment][:commentable_id]
  end

  def set_authorize
    authorize(@comment || Comment)
  end

  def get_comment
    @comment = Comment.find params[:id]
  end

end
