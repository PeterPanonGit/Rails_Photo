require 'net/ssh'
require 'net/scp'
class ImageJob
  include DebHelper
  include ConstHelper

  def initialize(worker_name)
    @worker_name = worker_name
    #set_config(worker_name)
  end

  def set_config(worker_name)
    return if worker_name.nil?
    #@worker_name = worker_name.to_s
    file = Rails.root.join('config/config.secret')
    config = get_param_config(file, :workservers, worker_name.to_sym)
    return if config.blank?
    #@queue = worker_name.to_sym
    @user_host = config["user_host"]
    @login_cmd = config["login_cmd"]
    @local_tmp_path = Rails.root.join("tmp/#{worker_name}")
    if !Dir.exist?(@local_tmp_path)
      Dir.mkdir(@local_tmp_path)
    end
    @remote_neural_path = config["remote_neural_path"]
    @content_image_name = "content.jpg"
    @style_image_name = "style.jpg"
    @admin_email = config["admin_email"]
    ##debug
    log "config: #{config.to_s}"
  end

  def execute
    log "-----------------------Start Demon: #{@worker_name}---------------------"
    while true
      item = get_images_from_queue  # QueueImage.where("status = #{STATUS_NOT_PROCESSED}").order('created_at ASC')
      if !item.nil? #&& imgs.count > 0 && !imgs.first.nil?
        log("Images: #{item.attributes}")
        set_config(@worker_name)
        #item = imgs.first
        res = execute_image(item)
      else
        log "-----------------------Stop Demon---------------------------"
        return "Zero"
      end
      #sleep 5
    end
  end

  def get_images_from_queue
    # give high priority to users who has not processed any images before
    cl = Client.find_by_sql("select * from clients c where lastprocess is null and exists (select * from queue_images q where c.id = q.client_id and status = 1) order by created_at ASC")
    if cl.count == 0
      cl = Client.find_by_sql("select * from clients c where exists (select * from queue_images q where c.id = q.client_id and status = #{STATUS_NOT_PROCESSED}) order by lastprocess ASC")
    end
    return nil if cl.count == 0
    cl = cl.first
    log("Client: #{cl.attributes}")
    cl.queue_images.where("status = 1").order('created_at ASC').first
  end

  def get_server_name
    #log "ssh -i '/home/huapu/Downloads/paral_style.pem' ubuntu@ec2-35-162-222-102.us-west-2.compute.amazonaws.com 'hostname'"
    log "login_cmd: #{@login_cmd}"
    log "user_host: #{@user_host}"
    output = `ssh #{@login_cmd} #{@user_host} 'hostname'`
    log "server name is: #{output}"
    output
  end

  def execute_image(item)
    return nil if item.nil?
    process_time = Time.now

    log "-----------------------"
    log "execute_image item.id = #{item.id}"
    #
    item.update({:status => STATUS_IN_PROCESS, :stime => process_time})
    item.style.update(use_counter: item.style.use_counter+1)
    # Check connection to workserver
    #log "item.update: #{item.to_s}"
    #server_name = get_server_name
    #log "get_server_name returns: #{server_name}"
    #return "get_server_name: false" if server_name.nil?
    #Upload images to workserver
    @content_image_name = "content.#{item.content.image.to_s.split('.').last}"
    @style_model_name = "#{item.style.init}"
    log "content_image_name: #{@content_image_name}"
    log "style_model_name: #{@style_model_name}"
    #log "4"
    return "upload_content_image: false" unless upload_image(item.content.image, "content/#{@content_image_name}")
    log "upload_content_image"
    #Run process
    name = "output.jpg"
    log "rendering on #{@user_host} with output: #{@remote_neural_path}/output/output.jpg"
    `ssh #{@login_cmd} #{@user_host} "source ~/tensorflow/bin/activate && cd ~/#{@remote_neural_path} && if [ -f '#{name}' ]; then rm #{name}; fi && python evaluate.py --checkpoint=models/#{@style_model_name}/style_15 --in-path=content/#{@content_image_name} --out-path=#{name} > out.log"`
    log "send_start_process_comm"
    #log "6"
    # Wait processed images
    loc =  "#{@local_tmp_path}/#{name}"
    rem = "#{@user_host}:~/#{@remote_neural_path}/#{name}"
    log "download_image: from #{rem} to #{loc}"
    `scp #{@login_cmd} #{rem} #{loc}`
    errors = save_image(0,item,loc)
    log "save_image: #{name}"
    item.update(progress: 1)
    #
    log "process time: #{Time.now - process_time}"
    process_time = Time.at(Time.now - process_time)
    #
    if errors.nil?
      item.update({:status => item.end_status, :ftime => Time.now, :ptime => process_time})
      "OK"
    else
      item.update({:status => STATUS_ERROR, :result => errors, :ftime => Time.now, :ptime => process_time})
      ImageMailer.send_error(@admin_email,"",item,errors).deliver_now
      log "execute_image: #{errors}"
    end
    item.client.update({:lastprocess => Time.now})
    #Change status to PROCESSED
    #item.status = @STATUS_PROCESSED
    #item.save
  end

  protected

  def save_image(iter_num,item,loc)
    log "save_image: iter_num = #{iter_num}, loc = #{loc}"
    pimg = Pimage.new
    pimg.queue_image_id = item.id
    pimg.iterate = iter_num
    begin
      File.open(loc) do |f|
        pimg.imageurl = f
      end
      pimg.save!
    rescue
      return false
    end
    return nil
  end

  def upload_image(loc_file_name, remote_file_name)
    begin
      # Downloads files
      rem = "#{@remote_neural_path}/#{remote_file_name}"
      loc =  Rails.root.join("public#{loc_file_name}")
      log "uploading #{loc} to #{rem}"
      return false if !File.exist?(loc)
      `scp #{@login_cmd} #{loc} #{@user_host}:~/#{rem}`
      return true
    rescue

    end
    false
  end

  def log(msg)
    write_log(msg, @worker_name)
  end
end