require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  # 初期化
  def setup
    ActionMailer::Base.deliveries.clear                                   #配列deliveriesは変数なので、setupメソッドでこれを初期化しておかないと、並行して行われる他のテストでメールが配信されたときにエラーが発生する　=> 以下有効なユーザー登録に対するテストで出る
  end
  
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
  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do                                 #ブロック内の処理を実行する直前と、実行した直後のUser.countの値を比較
      post users_path, params:{ user:{                                    
                                        name: "Example User",   
                                        email: "user@example.com",
                                        password: "password",
                                        password_confirmation: "password"} }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size                  #配信されたメッセージがきっかり1つであるかどうかを確認
    user = assigns(:user)                                               #assignsメソッドを使うと対応するアクション内のインスタンス変数にアクセスできるようになります　=> Usersコントローラのcreateアクションでは@userというインスタンス変数にアクセス
    assert_not user.activated?
    # 有効化していない状態でログインしてみる
    log_in_as(user)
    assert_not is_logged_in?
    # 有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # 有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!                                                      #POSTリクエストを送信した結果を見て、指定されたリダイレクト先に移動するメソッド
    assert_template 'users/show'                                          #送信先　views/users/show
    assert is_logged_in?                                                  #ユーザー登録後のログインのテスト   test/test.helper.rb
  end
  
end
