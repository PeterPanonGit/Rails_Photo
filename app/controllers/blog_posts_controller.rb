class BlogPostsController < ApplicationController
  before_action :set_authorize, only: [:edit, :new, :create, :update, :destroy]

  def index
    @blog_posts = BlogPost.order('created_at DESC').all
  end

  def show
    @blog_post = BlogPost.find params[:id]
    @comment = @blog_post.comments.new
    @comments = @blog_post.comments
  end

  def new
    @blog_post = BlogPost.new
  end

  def create
    @blog_post = BlogPost.new blog_post_params

    if @blog_post.save
      redirect_to blog_posts_path, notice: "The blog post is saved"
    else
      render action: "new", alert: @blog_post.errors.full_messages.to_sentence
    end
  end

  def edit
    @blog_post = BlogPost.find params[:id]
  end

  def update
    @blog_post = BlogPost.find params[:id]
    if @blog_post.update_attributes(blog_post_params)
      redirect_to blog_posts_path, notice: "The blog post is updated."
    else
      render action: "edit", alert: @blog_post.errors.full_messages.to_sentence
    end
  end

  def destroy
    @blog_post = BlogPost.find params[:id]
    @blog_post.destroy
    redirect_to blog_posts_path
  end

  def pundit_user
    current_client
  end

  private

  def blog_post_params
    params.require(:blog_post).permit(:title, :body)
  end

  def set_authorize
    authorize BlogPost
  end

end
