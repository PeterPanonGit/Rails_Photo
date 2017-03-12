class QueueImagesController < ApplicationController
  include WorkerHelper
  include ConstHelper
  before_action :set_queue_image, only: [:show, :edit, :update, :destroy, :visible, :hidden, :like_image, :unlike_image, :post_facebook]
  after_action :verify_authorized, except: [:tag, :loaded]
  before_action :increment_credit, only: [:post_facebook]
  before_action :not_image_owner, only: [:like_image, :unlike_image]

  def pundit_user
    current_client
  end

  # GET /queue_images
  # GET /queue_images.json
  def index
    #@items= current_client.queue_images.all.order('created_at DESC')
    #@items= policy_scope(current_client.queue_images).order('created_at DESC').paginate(:page => params[:page], :per_page => 6)
    authorize QueueImage
    @items = policy_scope(current_client.queue_images).order('created_at DESC').paginate(:page => params[:page], :per_page => 6)
    #@items= QueueImage.where("status > 9").order('ftime DESC').paginate(:page => params[:page], :per_page => 6)
  end

  # GET /queue_images/1
  # GET /queue_images/1.json
  def show
    authorize @queue_image
  end

  # GET /queue_images/new
  def new
    @image_count = current_client.queue_images.count
    @maximum_reached = current_client.reached_maximum?
    @my_queue_images = current_client.queue_images
    @queue_image = QueueImage.new
    @styles = Style.where(status: ConstHelper::GALLERY_STYLE_IMAGE).order('use_counter desc')
    @tags = @styles.tag_counts_on(:tags)
    @active = Style.find(params[:style]) if params[:style]
    @mixing_level = params[:mixing_level]
    @is_premium = params[:is_premium]
    if @my_queue_images
      @my_styles = @my_queue_images.map { |qi| qi.style }
      @my_styles.uniq!
      @my_styles.compact!
      @my_pictures = @my_queue_images.map { |qi| qi.content }
      @my_pictures.uniq!
      @my_pictures.compact!
    end
    authorize @queue_image
    respond_to do |format|
      format.html { render :new}
      format.js
    end
  end

  # GET /queue_images/1/edit
  def edit

  end

  # POST /queue_images
  # POST /queue_images.json
  def create
    authorize QueueImage
    unless valid_queue_image_params
      redirect_to new_queue_image_path
      return
    end

    max_reached = current_client.reached_maximum?
    qi_service = QueueImageService.new queue_image_params, current_client
    save_status = qi_service.create_queue

    if save_status && max_reached
      current_client.delete_older_image
    end

    respond_to do |format|
      if save_status
        start_workers()
        current_client.decrement! :credits, Client.credits_for_image if params[:queue_image][:is_premium] == "true"
        format.html { redirect_to queue_images_path, notice: 'Image was successfully added to the queue for processing. Low-resolution images takes about 10 seconds to process, and high-resolution images takes 20 seconds to 4 minutes depending on the image size' }
        format.json { render :show, status: :created, location: @queue_image }
      else
        format.html { redirect_to new_queue_image_path, alert: qi_service.errors.to_sentence }
        format.json { render json: @queue_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /queue_images/1
  # PATCH/PUT /queue_images/1.json
  def update
    respond_to do |format|
      if @queue_image.update(queue_image_params)
        format.html { redirect_to @queue_image, notice: 'Queue image was successfully updated.' }
        format.json { render :show, status: :ok, location: @queue_image }
      else
        format.html { render :edit }
        format.json { render json: @queue_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /queue_images/1
  # DELETE /queue_images/1.json
  def destroy
    content = @queue_image.content
    puts "AAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    puts content.queue_images.count
    puts "AAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    if content.queue_images.count > 1
      @queue_image.destroy
    else
      content.destroy
    end
    respond_to do |format|
      format.html { redirect_to queue_images_url, notice: 'Images removed.' }
      format.json { head :no_content }
    end
  end

  def visible
    @queue_image.update(status: STATUS_PROCESSED)
    respond_to do |format|
      format.html { redirect_to queue_images_url, notice: 'Images become publicly visible.' }
      format.json { head :no_content }
    end
  end

  def hidden
    @queue_image.update(status: STATUS_HIDDEN)
    respond_to do |format|
      format.html { redirect_to queue_images_url, notice: 'The images are hidden.' }
      format.json { head :no_content }
    end
  end

  def like_image
    Like.transaction do
      today_likes = current_client.likes.where created_at: (Time.now - 24.hours)..Time.now
      current_client.increment!(:credits, 1) if today_likes.count < 3
      Like.create(queue_id: @queue_image.id, client_id: current_client.id)
      @queue_image.increment! :likes_count, 1
      @queue_image.client.increment! :credits, 1
    end
    respond_to do |format|
      format.html { redirect_to queue_images_url}
      format.js
    end
  end

  def unlike_image
    Like.transaction do
      today_likes = current_client.likes.where created_at: (Time.now - 24.hours)..Time.now
      current_client.decrement!(:credits, 1) if today_likes.count > 0 && today_likes.count < 4
      Like.where("client_id = #{current_client.id} and queue_id = #{@queue_image.id}").destroy_all
      @queue_image.decrement! :likes_count, 1
      @queue_image.client.decrement! :credits, 1
    end
    respond_to do |format|
      format.html { redirect_to queue_images_url}
      format.js
    end
  end

  def loaded
    @queue_image = QueueImage.find(params[:id])
    respond_to do |format|
      if @queue_image.result_image
        format.js
      else
        format.js { render 'loaded', status: 501 }
      end
    end
  end

  def post_facebook
    @graph = Koala::Facebook::API.new(current_client.token)
    photo = @queue_image.result_image.imageurl.thumb400.url
    if photo
      @graph.put_picture("#{request.protocol}#{request.host_with_port}#{photo}")
    end

    respond_to do |format|
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_queue_image
    @queue_image = QueueImage.find(params[:id])
    authorize @queue_image
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def queue_image_params
    params.require(:queue_image).permit(:content_id, :content_image, :mixing_level, :is_premium, :style_image, :style_id, :init_str, :status, :result, :init, :end_status)
  end

  def valid_queue_image_params
    if params[:queue_image][:content_image].nil? && params[:queue_image][:content_id].nil?
      flash[:alert] = "Please add or select an image for rendering"
      return false
    end
    true
  end

  def decrement_credit
    current_client.decrement! :credits, 1
  end

  def increment_credit
    current_client.increment! :credits, 1
  end

  def not_image_owner
    if @queue_image.client == current_client
      redirect_to queue_images_url
    end
  end
end
