require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  
  # fixtureでuser変数を定義する
  def setup
    @user = users(:michael)
    remember(@user)
  end
  
  # current_userは、セッションがnilのときに右のユーザーを返す
  test "current_user return right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end
  
  # :remember_digestが間違っている場合、current_userはnilを返す
  test "current_user return nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
  
end