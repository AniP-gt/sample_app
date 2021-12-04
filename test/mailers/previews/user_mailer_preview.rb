# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

# アカウント有効化のプレビューメソッド
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    user = User.first                       #変数に代入　=> 開発用データベースの最初のユーザーになるように定義
    user.activation_token = User.new_token  #アカウント有効化のトークンが必要なので、代入は省略できないため変数に代入する。なお、データベースのユーザーはこの値を実際には持っていないため変数に代入
    UserMailer.account_activation(user)     #上記変数userが引数として渡す
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    UserMailer.password_reset
  end

end
