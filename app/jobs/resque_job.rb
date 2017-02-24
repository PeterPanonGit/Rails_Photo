
class ResqueJob
  #@@queue_class = :server1
  @queue = :server1

  def initialize
    #@queue = @@queue_class
  end

  def self.perform(*arg)
    #return false if arg.blank? || arg[0].blank?
    #`kill -s USR2 $(head -n 1 #{ENV['RESQUE_PID_FILE']})`
    img_job = ImageJob.new(@queue)
    #img_job.set_config()
    img_job.execute
    #`kill -s CONT $(head -n 1 #{ENV['RESQUE_PID_FILE']})`
  end

end
