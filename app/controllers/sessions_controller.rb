class SessionsController < ApplicationController
  
  def new
  end
  
  #ユーザーのログイン
  def create
    user = User.find_by(email: params[:session][:email].downcase)              #変数userに送信されたメールアドレスを使って、データベースからユーザーを取り出す
    if user && user.authenticate(params[:session][:password])                  #ユーザーがデータベースにあり、かつ、認証に成功した場合にのみ
      if user.activated?                                                       #有効でないユーザーがログインすることのないようにする
        log_in user                                                            #helpers/sessions_helperのモジュール
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)  #app/models/user.rb  永続セッションのためにユーザーをデータベースに記憶する チェックボックスの送信結果を処理する(チェックボックスがオンの時に'1'、オフのときに'0')
        redirect_back_or user                                                  #リクエストされたURLが存在する場合はそこにリダイレクトし、ない場合は何らかのデフォルトのURLにリダイレクトする
      else
        message = "Account not activated."                                     #変数message
        message += "Check your email for the activation link."                 #前述の変数messageと組わせて上書き
        flash[:warning] = message                                             
        redirect_to root_url
      end
    else
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      flash.now[:danger] = 'Invalid email/password combination'  #文字列    
      render 'new'  #views/sessions/new
    end
  end
  
  # セッションを破棄する（ユーザーのログアウト）
  def destroy
    log_out if logged_in?   #sessions_helper.rbより  ログイン中の場合のみログアウトする※バグ１つ目をクリア詳細は以下
    redirect_to root_url
  end
  
end

#--以下備考欄--
# 特殊変数flash　=> seccessとdangerのキーを持つ  falsh.now => その後リクエストが発生した時に消滅する（他のページに遷移した時など、つまりその場限りのメッセージ）
# params[:session] => { session: { password: "foobar", email: "user@example.com" } }
#　authenticateメソッド => 引数に渡された文字列（パスワード）をハッシュ化した値と、データベース内にあるpassword_digestカラムの値を比較

# ※ログアウト時の小さなバグ２つ以下
# 1.同じサイトを複数のタブ（あるいはウィンドウ）で開いている時に、１つのタブでログアウトし、もう一つでログアウトするとエラーが発生。
# 原因　=>　　もう1つのタブで "Log out" リンクをクリックすると、current_userがnilとなってしまうため、log_outメソッド内のforget(current_user)が失敗してしまうから
# 解決方法　=> ユーザーがログイン中の場合にのみログアウトさせる必要がある

# 2.Firefoxでログアウトし、Chromeではログアウトせずにブラウザを終了させ、再度Chromeで同じページを開くと発生
# 原因 => Firefoxでログアウトしたときに（リスト 9.11）ユーザーのremember_digestが削除されているにもかかわらず、Chromeでアプリケーションにアクセスしたときに次の文を実行してしまうからです。
# BCrypt::Password.new(remember_digest).is_password?(remember_token)
# すなわち上のremember_digestがnilになるので、bcryptライブラリ内部で例外が発生します。
# 解決方法　=> remember_digestが存在しないときはfalseを返す処理をauthenticated?に追加する