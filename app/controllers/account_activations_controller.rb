class AccountActivationsController < ApplicationController
    # アカウントを有効化するeditアクション
    def edit
        user = User.find_by(email: params[:email])
        if user && !user.activated? && user.authenticated?(:activation, params[:id])        #既に有効になっているユーザーを誤って再度有効化しないために必要です
          user.update_attribute(:activated,    true)                                        #変数userにactivatedキーの値がtrueという条件を更新                                      
          user.update_attribute(:activated_at, Time.zone.now)                               #変数userにactivated_atキーの値が現在の時刻に更新
          log_in user                                                                       #ログインユーザーの個人ページに遷移
          flash[:success] = "Account activated!"                                            #flashメッセージを表示
          redirect_to user                                          
        else
          flash[:danger] = "Invalid activation link"
          redirect_to root_url
        end
  end
end
