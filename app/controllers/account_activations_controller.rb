class AccountActivationsController < ApplicationController
    # アカウントを有効化するeditアクション
    def edit
        user = User.find_by(email: params[:email])
        if user && !user.activated? && user.authenticated?(:activation, params[:id])        #既に有効になっているユーザーを誤って再度有効化しないために必要です
          user.activate                                      #ユーザーモデルオブジェクト経由でアカウントを有効化する                                     
          log_in user                                                                       #ログインユーザーの個人ページに遷移
          flash[:success] = "Account activated!"                                            #flashメッセージを表示
          redirect_to user                                          
        else
          flash[:danger] = "Invalid activation link"
          redirect_to root_url
        end
  end
end