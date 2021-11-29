require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  
  #有効な情報を使ってユーザーログインをテストする
  def setup
    @user = users(:michael)         #test/fixtures/users.ymlで設定したテスト用ユーザーを変数@userに代入
  end
  
  # 有効なメールアドレス/無効なパスワードでログインする
  test "login with valid email/invalid password" do
    get login_path
    assert_template 'sessions/new'                                      #view/sessions/new
    post login_path, params: { session: { email:    @user.email,        #ログイン　=> メールアドレス、
                                          password: "invalid" } }       #無効なパスワード文字列
    assert_not is_logged_in?                                            #ログイン状態ではない場合は以下
    assert_template 'sessions/new'                                      #view参照
    assert_not flash.empty?                                             #変数flashの中身は空ではないか場合は以下
    get root_path                                                       #homeに遷移
    assert flash.empty?                                                 #変数flashは空ではない場合は終了
  end

# 有効な情報でログインしてからログアウトする
  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    assert is_logged_in?                                                  #ヘルパーメソッドより、ログイン状態であるか？
    assert_redirected_to @user                                            #リダイレクト先が正しいかどうかをチェック
    follow_redirect!                                                      #そのページに実際に移動、ログインパスのリンクがページにないかどうかで判定している
    assert_template 'users/show'                                          #指定したページを描写する
    assert_select "a[href=?]", login_path, count: 0                       #count: 0というオプションをassert_selectに追加すると、渡したパターンに一致するリンクが０かどうかを確認するようになります
    assert_select "a[href=?]", logout_path                                #ログアウトのパス
    assert_select "a[href=?]", user_path(@user)                           #テストユーザーへのパス
    delete logout_path                                                    
    assert_not is_logged_in?                                              #ログイン状態でないか？
    assert_redirected_to root_url      
    delete logout_path                                                    #２番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
    follow_redirect!
    assert_select "a[href=?]", login_path       
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
  
  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not_empty cookies[:remember_token]
  end

  test "login without remembering" do
    # cookieを保存してログイン
    log_in_as(@user, remember_me: '1')
    delete logout_path
    # cookieを削除してログイン
    log_in_as(@user, remember_me: '0')
    assert_empty cookies[:remember_token]
  end
  
end
