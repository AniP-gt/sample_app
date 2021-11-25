class SessionsController < ApplicationController
  
  def new
  end
  
  # 失敗時にもう一度loginページを表示
  def create
    user = User.find_by(email: params[:session][:email].downcase) #変数userに送信されたメールアドレスを使って、データベースからユーザーを取り出す
    if user && user.authenticate(params[:session][:password])     #ユーザーがデータベースにあり、かつ、認証に成功した場合にのみ
      log_in user  #helpers/sessions_helperのモジュール
      redirect_to user  
      #ユーザーログイン後にユーザー情報のページにリダイレクトする
    else
      #エラーメッセージを作成する
      flash.now[:danger] = 'Invalid email/password combination'   #変数flash
      render 'new'  #views/sessions/new
    end
  end
  
  def destroy
  end
  
end

#　authenticateメソッド => 引数に渡された文字列（パスワード）をハッシュ化した値と、データベース内にあるpassword_digestカラムの値を比較