require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  # テストユーザーの設定
  def setup
    @user = users(:michael)
  end
  
  # 編集の失敗テスト
  test "unsuccessful edit" do
    log_in_as(@user)                                                                    #テストユーザー  test/test_helper.rb                                                                                                     
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: "",                                 #nameは空欄、email、passwordは適当な文字列を入れる
                                             email: "foo@invalid",
                                             password: "foo",
                                             password_confirmation: "bar" } }
    assert_template 'users/edit'                                                        
  end

  # 編集の成功に対するテスト
  test "successful edit" do
    log_in_as(@user)
    get edit_user_path(@user)                                                         #getでeditへリクエスト
    assert_template 'users/edit'                                                      #editの呼び出し
    name = "Foo Bar"                                                                  #変数nameの定義
    email = "foo@bar.com"                                                             #変数emailの定義  
    patch user_path(@user), params: { user: { name: name,                             #nameが書き換わったか
                                              email: email,                           #emailが書き換わったか
                                              password: "",                           #パスワードは空欄で更新できるか
                                              password_confirmation: ""} }
    assert_not flash.empty?                                                           #flashメッセージが空でないかどうか
    assert_redirected_to @user                                                        #再度@userで呼び出し
    @user.reload                                                                      #データベースから最新のユーザー情報を読み込み直して、正しく更新されたかどうかを確認しているか
    assert_equal name, @user.name                                                     #DBの情報を元に、nameと@user.nameの比較をする
    assert_equal email, @user.email                                                   #同上　email版
  end

  # フレンドリーフォワーディングのテスト
  test "successful edit with frirendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name,
                                             email: email,
                                             password: "",
                                             password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end  

end
