require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  #テストユーザー
  def setup
    @user = users(:michael)
  end
  
  # /signupと/usersのパス
  test "should get new" do
    get signup_path
    get users_new_url
    assert_response :success
  end
  
  # ログインしていないときに編集をリダイレクトする必要があるテスト
  test "shuold redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  # ログインしていない場合のリダイレクトの更新をするテスト
  test "shuold redirect update when not logged in" do
    patch user_path(@user), params: {user: {name: @user.name,
                                            email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end
end
