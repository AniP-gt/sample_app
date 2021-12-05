# ユーザーがログインし続けるためのヘルパー
module SessionsHelper
  
  # 渡されたユーザーでログインする
  def log_in(user)
    # sessionメソッドで作成された一時cookiesは、ブラウザを閉じた瞬間に有効期限が終了します
    session[:user_id] = user.id   #変数session[:user_id]に代入　 ユーザーのブラウザ内の一時cookiesに暗号化済みのユーザーIDが自動で作成、DB上のuesr.idを検索 
  end
  
  # ユーザーのセッションを永続的にする　=> cookiesからユーザーを取り出せるようになります。
  def remember(user)
    user.remember                                                 #modelsのUserクラスの永続セッションのためにユーザーをデータベースに記憶するメソッド
    cookies.permanent.signed[:user_id] = user.id                  #ハッシュcookiesのキーにDB上のuser_idカラムを署名付きにし、20年永続する設定をした値を代入　 
    cookies.permanent[:remember_token] = user.remember_token      #DB上のremember.tokenカラムにに20年永続する設定した
  end
  
  #記憶トークンcookieに対するユーザーを返す 現在ログイン中のユーザーを返す（いる場合）
  def current_user
    if (user_id = session[:user_id])                              #（ユーザーIDにユーザーIDのセッションを代入した結果）ユーザーIDのセッションが存在すれば  変数user_idに代入
      @current_user ||= User.find_by(id: user_id)                 # セッションにユーザーID（変数user_idより）が存在しない場合、このコードは単に終了して自動的にnilを返します。 変数current_userに代入
    elsif (user_id = cookies.signed[:user_id])                    # 上記ifで無かった場合、user.idにcookiesで署名したidを代入
      # raise                                                       # テストがパスすれば、この部分がテストされていないことがわかる（例外をあえて仕込む、テストのため）
      user = User.find_by(id: user_id)                            # 変数userに検索したidを代入する
      if user && user.authenticated?(:remember, cookies[:remember_token])    # 変数userかつcookiesのremember_tokenカラムを含んだユーザーが認証済みであった場合
        log_in user                                               # 変数userはログイン
        @current_user = user                                      # 最後に変数current_userに変数userを代入（ログアウトのため）
      end
    end
    # 現在ログイン中のユーザーを返す（いる場合）（一時セッション）
    # if session[:user_id]
    #   # @current_user = @current_user || User.find_by(id: session[:user_id])  変数@current_userに「変数@current_userがnilであった場合、Userからfindしたidを代入する　↓は短縮形
    #   @current_user ||=User.find_by(id: session[:user_id])   #セッションにユーザーIDが存在しない場合、このコードは単に終了して自動的にnilを返します。
    # end
  end
  
  # 渡されたユーザーがcurrent_userであればtureを返す
  def current_user?(user)
    user && user == current_user
  end
  
  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?    #current_userがnilではないという状態である =>sessionにユーザーidが存在している
  end
  
    # 現在のユーザーをログアウトする
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
  
  # 永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  #現在のユーザーをログアウトする
  def log_out
    forget(current_user)        #コントローラーのUser.forgetメソッドに引数に変数current_userを入れる
    session.delete(:user_id)    #セッションからユーザーIDを削除
    @current_user = nil         #現在のユーザーをnilの状態にしておく　
  end
  
  # 記憶したURL（もしくはデフォルト値）にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default) 
    session.delete(:forwarding_url)
  end
  
  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?  #GETリクエストだけが送られたURLをsession変数の:forwarding_urlキーに格納、エラー回避のためif文にて、GETが送られてきたか確認。request.original_urlでリクエスト先が取得できます
  end
  
end




# --以下備考欄--
# find(n) => ユーザーidを渡す　ユーザーidが無い場合はエラー（例外）となる
# find_by => 詳細な値（idやemailなど）を渡し、値が無い場合はnilを返す
# ※「||=」について　変数の値がnilなら変数に代入するが、nilでなければ代入しない（変数の値を変えない）
# ※ permanentメソッド => 20年で期限切れになるcookies設定がされているメソッド