require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  test "invalid signup information" do
    get signup_path                                                       #getメソッドでユーザー登録ページにアクセス
    assert_no_difference 'User.count' do                                  #ブロックを実行する前後で引数の値（User.count）が変わらないことをテスト
      post users_path, params: {user: {                                   #postメソッドでusers_pathにリクエスト送信、params[:user]ハッシュにまとめる
                                        name: "",   
                                        email: "user@invalid",
                                        password: "foo",
                                        password_confirmation: "bar"} }
    end
    assert_template 'users/new'                                           #送信に失敗した時にviews/users/newへ再描画される画面
  end
  
  # 有効なユーザー登録に対するテスト
  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do                                 #ブロック内の処理を実行する直前と、実行した直後のUser.countの値を比較
      post users_path, params:{ user:{                                    
                                        name: "Example User",   
                                        email: "user@example.com",
                                        password: "password",
                                        password_confirmation: "password"} }
    end
    follow_redirect!                                                      #POSTリクエストを送信した結果を見て、指定されたリダイレクト先に移動するメソッド
    assert_template 'users/show'                                          #送信先　views/users/show
  end
  
end
