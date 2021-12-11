# Railsの全コントローラー
class ApplicationController < ActionController::Base
  include SessionsHelper  #app/helpers/session_helper


    private

    # ユーザーのログインを確認する　　logged_in_userメソッドをApplicationコントローラに移す
    def logged_in_user                #app/controllers/users_controller.rb
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
