class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  def create
    @micropost = current_user.microposts.build(micropost_params)          #新しいマイクロポストをbuildするためにUser/Micropost関連付けを使う
    if @micropost.save                                                    
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])         #Micropostsコントローラのcreateアクションへの送信が失敗した場合に備えて、必要なフィード変数をこのブランチで渡しておく
      render 'static_pages/home'
    end
  end

  def destroy
  end

  private

# micropost_paramsでStrong Parametersを使っていることにより、マイクロポストのcontent属性だけがWeb経由で変更可能
    def micropost_params
      params.require(:micropost).permit(:content)
    end
end

