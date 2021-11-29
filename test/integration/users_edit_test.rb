require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  # テストユーザーの設定
  def setup
    @user = users(:michael)
  end
  
  # 編集の失敗テスト
  test "unsuccessful edit" do
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: "",
                                             email: "foo@invalid",
                                             password: "foo",
                                             password_confirmation: "bar" } }
    assert_template 'users/edit'
  end

end
