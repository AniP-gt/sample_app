# ユーザー登録時のコントロール
class UsersController < ApplicationController
  # beforeアクション定義
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy] #ログイン済みユーザーかどうか確認
  before_action :correct_user,   only: [:edit, :update]                   #正しいユーザーかどうか確認
  before_action :admin_user,     only: :destroy                           #削除アクション
  
  # 全てのユーザーを表示する
  def index
    @users = User.paginate(page: params[:page])   #Usersをページネートする  paginate　=> Gemfileより　、view/index.htmlのwill_paginateに連動
  end
  
  #DBからユーザーを取り出す
  def show
    @user = User.find(params[:id])                      #modelのクラスUserからidを取り出す
  end
  
  #form_withの引数で必要となるUserオブジェクトを作成（新規ユーザー登録アクション）
  def new
    @user = User.new
  end
  
  #フォーム送信を受け取り、ユーザーの保存（or失敗）し、再度の送信用のユーザー登録ページを表示する
  def create
    @user = User.new(user_params) 
    if @user.save                                       #保存の成功をここで扱う
        @user.send_activation_email                     #ユーザーモデルオブジェクトからメールを送信する
        flash[:info] = "Please check your email to activate your account."
        redirect_to root_url    
      else
      render 'new'                                      #views/users/new
    end
  end
  
  # ユーザーの編集画面
  def edit
    # @user = User.find(params[:id])                    #beforeで設定したため不要
  end
  
  # ユーザーの更新フォーム
  def update
    # @user = User.find(params[:id])                    #beforeで設定したため不要
    if @user.update(user_params)                        #更新に成功した場合
       flash[:success] = "Profile update"               
       redirect_to @user
    else
      render 'edit'                                     #エラーの場合、editにもどる
    end
  end
  
  # ユーザー削除
  def destroy
    User.find(params[:id]).destroy                      #HTTPのDELETEリクエスト=>destroyアクションを対象のユーザーidに適用
    flash[:success] = "User deleted"                    #flashメソッドにより成功ならばコメント
    redirect_to users_url                               #/usersに遷移
  end
  
  private #外部から使えないキーワード
  
  #createアクションでStrong Parametersを使う
  #:user属性を要求し、名前、メールアドレス、パスワード、パスワードの確認のカラムをそれぞれ許可し、それ以外のカラムを許可しない
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
  
  # beforeアクション
  
  # ログイン済みユーザーかどうか確認
  def logged_in_user
    unless logged_in?                       #ログインしていなければ
      store_location                        #アクセスしようとしたURLを覚えておく
      flash[:danger] = "Please log in."     #falsh変数にてメッセージ
      redirect_to login_url                 #ログイン画面に遷移
    end
  end
  
  # 正しいユーザーかどうか確認
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)  #sessions/helper => current_userメソッド
  end
  
  # destroyアクションを管理者だけに限定する =>サイトを正しく防衛するため
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
  
end
