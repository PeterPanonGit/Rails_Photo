require 'test_helper'

class ProcessImageJobTest < ActiveJob::TestCase
  test "get server name" do
    j = ImageJob.new(:server1)
    j.set_config(:server1)
    hostname = j.get_server_name
    puts hostname

    #item = j.get_images_from_queue
    #puts "item: #{item}"
    #j.execute_image("test")

    assert true
  end
end
