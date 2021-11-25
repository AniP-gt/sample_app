module SessionsHelper
  
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id   #ユーザーのブラウザ内の一時cookiesに暗号化済みのユーザーIDが自動で作成
  end
  
  # 現在ログイン中のユーザーを返す（いる場合）
  def current_user
    if session[:user_id]
      # @current_user = @current_user || User.find_by(id: session[:user_id])
      @current_user ||=User.find_by(id: session[:user_id])   #セッションにユーザーIDが存在しない場合、このコードは単に終了して自動的にnilを返します。
    end
  end
  
  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?    #current_userがnilではないという状態である
  end
  
end
