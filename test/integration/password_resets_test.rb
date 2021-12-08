require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

# テストユーザー
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

# パスワード再設定の統合テスト
  test "password resets" do
    get new_password_reset_path                                             #getの設定
    assert_template 'password_resets/new'                                   #ページの表示
    assert_select 'input[name=?]', 'password_reset[email]'                  #HTMLのinputタグ、password_resetメソッド表示
    # メールアドレスが無効
    post password_resets_path, params: { password_reset: { email: "" } }    #emailが空の場合
    assert_not flash.empty?                                                 #flash.emptyである場合、falseを主張
    assert_template 'password_resets/new'                                   #ページの表示
    # メールアドレスが有効
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest          #@userのカラムreset_digestと、リロードしたカラムと比較しない
    assert_equal 1, ActionMailer::Base.deliveries.size                      #配信されたメッセージがきっかり1つであるかどうかを確認します
    assert_not flash.empty? 
    assert_redirected_to root_url
    # パスワード再設定フォームのテスト
    user = assigns(:user)                                                   #アクション内のインスタンス変数にアクセス、user情報                                                  
    # メールアドレスが無効
    get edit_password_reset_path(user.reset_token, email: "")               
    assert_redirected_to root_url
    # 無効なユーザー
    user.toggle!(:activated)                                                #activatedをしない =>無効なユーザー
    get edit_password_reset_path(user.reset_token, email: user.email)       #
    assert_redirected_to root_url
    user.toggle!(:activated)
    # メールアドレスが有効で、トークンが無効
    get edit_password_reset_path('wrong token', email: user.email)          #
    assert_redirected_to root_url
    # メールアドレスもトークンも有効
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email    #inputタグに正しい名前、type="hidden"、メールアドレスがあるかどうかを確認します。
    # 無効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
    # パスワードが空
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'
    # 有効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end
end