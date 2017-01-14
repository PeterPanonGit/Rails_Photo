require 'test_helper'
  include Devise::TestHelpers

class QueueImagesControllerTest < ActionController::TestCase
  setup do
    @queue_image = queue_images(:one)
    @client = clients(:one)
    #@client.register!
    sign_in @client
    #get client_session_path
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:queue_images)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create queue_image" do
    assert_difference('QueueImage.count') do
      post :create, queue_image: { content_id: @queue_image.content_id, init_str: @queue_image.init_str, end_status: @queue_image.end_status, status: @queue_image.status, style_id: @queue_image.style_id, client_id: @queue_image.client_id }
    end

    assert_redirected_to queue_image_path(assigns(:queue_image))
  end

  test "should show queue_image" do
    get :show, id: @queue_image
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @queue_image
    assert_response :success
  end

  test "should update queue_image" do
    patch :update, id: @queue_image, queue_image: { content_id: @queue_image.content_id, init_str: @queue_image.init_str, end_status: @queue_image.end_status, status: @queue_image.status, style_id: @queue_image.style_id, client_id: @queue_image.client_id }
    assert_redirected_to queue_image_path(assigns(:queue_image))
  end

  test "should destroy queue_image" do
    assert_difference('QueueImage.count', -1) do
      delete :destroy, id: @queue_image
    end

    assert_redirected_to queue_images_path
  end
end
