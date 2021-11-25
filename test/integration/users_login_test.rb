require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  
  #有効な情報を使ってユーザーログインをテストする
  def setup
    @user = users(:michael)
  end
  
  
  # フラッシュメッセージの残留をキャッチするテスト
  test "login with invalid information" do  
    get login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    assert_redirected_to @user                                              #リダイレクト先が正しいかどうかをチェック
    follow_redirect!                                                        #ログインパスのリンクがページにないかどうかで判定している
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0                         #count: 0というオプションをassert_selectに追加すると、渡したパターンに一致するリンクが０かどうかを確認するようになります
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)                                       
  end
  
end
