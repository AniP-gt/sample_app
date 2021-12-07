class PasswordResetsController < ApplicationController
  def new
  end
  # パスワード再設定用のcreateアクション
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)       #インスタンス変数userにemailキーのpassword_resetとemail値を小文字にして代入
    if @user
      @user.create_reset_digest                                                 #createメソッドの
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
end
