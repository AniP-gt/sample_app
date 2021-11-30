# ユーザー登録時のコントロール
class UsersController < ApplicationController
  # beforeアクション定義
  before_action :logged_in_user, only: [:edit, :update] #編集と更新時のみ
  
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
      log_in @user                                      #ユーザー登録中にログインする =>　登録完了後自動でログイン後のユーザー画面へ遷移
      flash[:success] = "Welcome to the Sample App!"    #変数falshにリダイレクト後のメッセージを表示
      redirect_to @user                                 #ユーザー登録に成功した場合はページを描画せずに別のページにリダイレクト　=>　プロフィールページへ
    else
      render 'new'                                      #views/users/new
    end
  end
  
  # ユーザーの編集画面
  def edit
    @user = User.find(params[:id])
  end
  
  # ユーザーの更新フォーム
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)                        #更新に成功した場合
       flash[:success] = "Profile update"               
       redirect_to @user
    else
      render 'edit'                                     #エラーの場合、editにもどる
    end
  end
  
  private #外部から使えないキーワード
  
  #createアクションでStrong Parametersを使う
  #:user属性を必須とし、名前、メールアドレス、パスワード、パスワードの確認の属性をそれぞれ許可し、それ以外を許可しない
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
  
  # beforeアクション
  
  # ログイン済みユーザーかどうか確認
  def logged_in_user
    unless logged_in?                       #ログインしていなければ
      flash[:danger] = "Please log in."     #falsh変数にてメッセージ
      redirect_to login_url                 #ログイン画面に遷移
    end
  end
  
end
