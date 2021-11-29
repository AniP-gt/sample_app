# ユーザー登録のコントローラー
class User < ApplicationRecord
  attr_accessor :remember_token                               #インスタンス変数 永続セッションのための仮想の属性　メソッドの枠を超えてアクセスできる特殊な変数
  before_save { self.email = email.downcase}                  #emailの小文字化
  validates :name, presence: true, length: { maximum: 50}     #name属性の存在性を検証、最大50文字まで = validates(:name, presence: true)
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i    #完全な正規表現
  validates :email, presence: true, length: { maximum: 255},  #emailの存在性を検証、最大255文字まで
                    format: {with: VALID_EMAIL_REGEX},        #formatオプションを用いて、引数に正規表現を取る
                    uniqueness: {case_sensitive: false}       #メールアドレスの大文字小文字を無視した一意性の検証
  has_secure_password                                         #セキュアなパスワードを持っている　=>　パスワードのハッシュ化　⇔　DB内のpassword_digestという属性に保存　
                                                              # =>　dbファイルの「add_password_digest_to_users.rb」に追記　プラスauthenticateメソッドも使える以下
  validates :password, presence: true, length: {minimum: 6}   #password属性の存在性を検証、最小6文字から

# fixture向けのdigestメソッドを追加
# digestメソッドをUserクラス自身に配置して、クラスメソッドにする
# 渡された文字列のハッシュ値を返す
  def User.digest(string)
    # Railsのsecure_passwordのソースコードより以下
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :   #変数costに代入　=> コストパラメータをテスト中は最小にし、本番環境ではしっかりと計算する方法
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)                                #パスワードの生成用コード、costはコストパラメータ => コストパラメータでは、ハッシュを算出するための計算コストを指定
  end
  # => test/fixtures/users.ymlでユーザーログイン用のテスト設定
  
  
  
# 以下よりユーザーが明示的にログアウトを実行しない限り、ログイン状態を維持する
# ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64                               #A–Z、a–z、0–9、"-"、"_"のいずれかの文字（64種類）からなる長さ22のランダムな文字列を返します
  end
  
#永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token                             #self = インスタンス変数remember_token 変数に代入 以下参照　上記のメソッドUser.new_tokenを代入
    update_attribute(:remember_digest, User.digest(remember_token))  #記憶ダイジェストを更新　=>　DB上の:remember_digest及び上記User.digest(string)をUser.digest(remember_token)に更新、以下の処理につながる
  end
  
# 渡された上記のトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)                                      #ローカル変数remember_token　=> アクセサとは異なる
    return false if remember_digest.nil?                                  #記憶ダイジェストがnilの場合にfalseを返す ログアウトバグ２つ目の対処
    BCrypt::Password.new(remember_digest).is_password?(remember_token)    #渡されたトークン（remember_token）がDB上のremember_digestと一致することを確認します。　bcryptで暗号化されたパスワードを、トークンと直接比較
  end
  
# ユーザーのログイン情報を破棄する（ログアウト、永続セッションを終了）
  def forget
    update_attribute(:remember_digest, nil)                        #user.rememberの取り消し　=> remember_digestをnilで更新
  end
  
end

# --以下備考欄--
#　authenticateメソッド => 引数に渡された文字列（パスワード）をハッシュ化した値と、データベース内にあるpassword_digestカラムの値を比較
#※「トークン」とは、パスワードの平文と同じような秘密情報です。パスワードとトークンとの一般的な違いは、パスワードはユーザーが作成・管理する情報であるのに対し、トークンはコンピューターが作成・管理する情報である点です。
# selfというキーワードを使わないと、Rubyによってremember_tokenという名前のローカル変数が作成されてしまいます。 つまり、「remember_token」というrememberメソッド内で使えるローカル変数となってしまう
# cookiesメソッド　=>　２つのハッシュ値 、value（値）とexpires（有効期限）（expiresは省略可　20年で有効期限切れになる設定は、Railsのpermanentに専用メソッドが追加）