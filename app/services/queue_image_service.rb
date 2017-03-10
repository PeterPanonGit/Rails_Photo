class QueueImageService
  include ConstHelper
  def initialize params, current_client
    @queue_params = params
    @current_client = current_client
  end

  def create_queue
    @save_status = false
    @errors = []
    QueueImage.transaction do
      if @queue_params[:content_id] && @queue_params[:content_id].length > 0
        ci = Content.find(@queue_params[:content_id])
        @save_status = true if ci
      else
        ci = Content.new(image: @queue_params[:content_image])
        @save_status = ci.save
        @errors += ci.errors.messages.values
      end
      si = Style.find(@queue_params[:style_id])
      @queue_image = @current_client.queue_images.new()
      @queue_image.content_id = ci.id
      @queue_image.style_id = si.id
      @queue_image.status = STATUS_NOT_PROCESSED
      @queue_image.end_status = STATUS_PROCESSED
      @queue_image.mixing_level = @queue_params[:mixing_level]
      @queue_image.is_premium = @queue_params[:is_premium]
      if @queue_params[:end_status].nil?
        @queue_image.end_status = STATUS_PROCESSED
      else
        @queue_image.end_status = @queue_params[:end_status].to_i
      end
      @save_status &= @queue_image.save
      @errors += @queue_image.errors.messages.values
    end
    @save_status
  end

  def save_status
    @save_status
  end

  def errors
    @errors.flatten
  end
end