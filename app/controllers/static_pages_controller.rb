# HTMLの各ページのコントロール
class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])       #フィード機能を導入するため、ログインユーザーのフィード用
    end 
  end

  def help
  end
  
  def about
  end
  
  def contact
  end
end
