class UsersController < ApplicationController
  
  #DBからユーザーを取り出す
  def show
    @user = User.find(params[:id])  #modelのUserからidを取り出す
  end
  
  #form_withの引数で必要となるUserオブジェクトを作成（新規ユーザー登録アクション）
  def new
    @user = User.new
  end
  
  #フォーム送信を受け取り、ユーザーの保存（or失敗）し、再度の送信用のユーザー登録ページを表示する
  def create
    @user = User.new(user_params) 
    if @user.save #保存の成功をここで扱う
      flash[:success] = "Welcome to the Sample App!"    #変数falshにリダイレクト後のメッセージを表示
      redirect_to @user     #ユーザー登録に成功した場合はページを描画せずに別のページにリダイレクト　=>　プロフィールページへ
    else
      render 'new'  #views/users/new
    end
  end
  
  private #外部から使えないキーワード
  
  #createアクションでStrong Parametersを使う
  #:user属性を必須とし、名前、メールアドレス、パスワード、パスワードの確認の属性をそれぞれ許可し、それ以外を許可しない
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
  
end
