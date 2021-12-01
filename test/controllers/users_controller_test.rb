require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  #テストユーザー
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end
  
  # /signupと/usersのパス
  test "should get new" do
    get signup_path
    get users_new_url
    assert_response :success
  end

  # ログインしていないときにインデックスをリダイレクトする必要があります
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end
  
  # ログインしていないときに編集をリダイレクトする必要があるテスト
  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  # ログインしていないときに更新をリダイレクトする必要があります
  test "should redirect update when not logged in" do
    patch user_path(@user), params: {user: {name: @user.name,
                                            email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  # 間違ったユーザーとしてログインした場合、編集をリダイレクトする必要があります
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end
  
  # 間違ったユーザーとしてログインした場合、更新をリダイレクトする必要があります
  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end
end
