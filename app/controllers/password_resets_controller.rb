class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]         #editアクションとupdateアクションのどちらの場合も正当な@userが存在する必要があるので、いくつかのbeforeフィルタを使って@userの検索とバリデーションを行う                    
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]         # （1）への対応　check_expirationメソッドは、有効期限をチェックするPrivateメソッドとして定義
  
  def new
  end
  
  # パスワード再設定用のcreateアクション
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)       #インスタンス変数userにemailキーのpassword_resetとemail値を小文字にして代入
    if @user
      @user.create_reset_digest                                                 #models/user.rbのメソッド
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end
  
  # パスワードを更新する
  def update
    if params[:user][:password].empty?                  # （3）への対応
      @user.errors.add(:password, :blank)               #パスワードが空だった時に空の文字列に対するデフォルトのメッセージを表示してくれるようになります
      render 'edit'
    elsif @user.update(user_params)                     # （4）への対応
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'                                     # （2）への対応
    end
  end 
  
  # 非公開
  private

    # ユーザーのパスワードパラメータ
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
    
    # ユーザーメール情報取得
    def get_user
      @user = User.find_by(email: params[:email])                 #params[:email]のメールアドレスに対応するユーザーをこの変数に保存
    end

    # 正しいユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? &&                        
              @user.authenticated?(:reset, params[:id]))          #arams[:id]の再設定用トークンと、authenticated?メソッドを使って、このユーザーが正当なユーザーである（ユーザーが存在する、有効化されている、認証済みである）ことを確認
        redirect_to root_url
      end
    end  

    # トークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
    
end



# updateアクション
# (1)パスワード再設定の有効期限が切れていないか
# (2)無効なパスワードであれば失敗させる（失敗した理由も表示する）
# (3)新しいパスワードが空文字列になっていないか（ユーザー情報の編集ではOKだった）
# (4)新しいパスワードが正しければ、更新する