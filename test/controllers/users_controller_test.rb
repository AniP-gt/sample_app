require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  # /signupと/usersのパス
  test "should get new" do
    get signup_path
    get users_new_url
    assert_response :success
  end

end
