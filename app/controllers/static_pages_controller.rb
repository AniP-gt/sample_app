# HTMLの各ページのコントロール
class StaticPagesController < ApplicationController
  def home
    @micropost = current_user.microposts.build if logged_in?        #current_userメソッドはユーザーがログインしているとき
  end

  def help
  end
  
  def about
  end
  
  def contact
  end
end
