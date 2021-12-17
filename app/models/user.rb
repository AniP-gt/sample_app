class User < ApplicationRecord
  has_many :microposts, dependent: :destroy                                 #has_many=>userとmicropost_user_idを紐づける、dependent:destroy=> ユーザーが削除されたときに、そのユーザーに紐付いた（そのユーザーが投稿した）マイクロポストも一緒に削除される
  has_many :active_relationships, class_name:  "Relationship",              #ActiveRelationshipモデルを探してしまい）Relationshipモデルを見つけることができません。followerというクラス名は存在しないので、ここでもRailsに正しいクラス名を伝える
                                  foreign_key: "follower_id",               #データベースの2つのテーブルを繋ぐ
                                  dependent:   :destroy  
  has_many :passive_relationships, class_name:  "Relationship",             #フォロワー機能
                                   foreign_key: "followed_id",
                                   dependent:   :destroy                                  
  has_many :following, through: :active_relationships, source: :followed    #1人のユーザーにはいくつもの「フォローする」「フォローされる」といった関係性の設定      :sourceパラメーターを使って、「following配列の元はfollowed idの集合である」ということを明示する
  has_many :followers, through: :passive_relationships, source: :follower   #フォロワー機能
  attr_accessor :remember_token, :activation_token, :reset_token            #インスタンス変数 永続セッションのための仮想の属性　メソッドの枠を超えてアクセスできる特殊な変数
  before_save   :downcase_email                                             #emailの小文字化 => downcase_emailメソッド参照
  before_create :create_activation_digest                                   #
  validates :name, presence: true, length: { maximum: 50}                   #name属性の存在性を検証、最大50文字まで = validates(:name, presence: true)
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i                  #完全な正規表現
  validates :email, presence: true, length: { maximum: 255},                #emailの存在性を検証、最大255文字まで
                    format: {with: VALID_EMAIL_REGEX},                      #formatオプションを用いて、引数に正規表現を取る
                    uniqueness: {case_sensitive: false}                     #メールアドレスの大文字小文字を無視した一意性の検証
  has_secure_password                                                       #セキュアなパスワードを持っている　=>　パスワードのハッシュ化　⇔　DB内のpassword_digestという属性に保存　
                                                                            # =>　dbファイルの「add_password_digest_to_users.rb」に追記　プラスauthenticateメソッドも使える以下
  validates :password, presence: true, length: {minimum: 6}, allow_nil: true   #password属性の存在性を検証、最小6文字から、空のパスワード（nil）を許可

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
  def authenticated?(attribute ,token)                           #引数attribute、tokenを設定
    digest = send("#{attribute}_digest")                         #変数digestにsendメソッドを使って引数attributeに文字列を代入し、変数に返す
    return false if digest.nil?                                  #変数digestがnilの場合にfalseを返す ログアウトバグ２つ目の対処
    BCrypt::Password.new(digest).is_password?(token)             #渡されたトークン（remember_token）がDB上のremember_digestと一致することを確認します。　bcryptで暗号化されたパスワードを、トークンと直接比較
  end
  
# ユーザーのログイン情報を破棄する（ログアウト、永続セッションを終了）
  def forget
    update_attribute(:remember_digest, nil)                        #user.rememberの取り消し　=> remember_digestをnilで更新
  end
  
# アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
    # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)                 #短時間で期限切れ(:reset_sent_at)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
    # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago         #パスワード再設定メールの送信時刻が、現在時刻より2時間以上前（早い）の場合
  end
  
  # ユーザーのステータスフィードを返す
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end
  
  
    # ユーザーをフォローする
  def follow(other_user)
    following << other_user                           #<<演算子（Shovel Operator）で配列の最後に追記することができます
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy          #other_user.id =>  userと紐づけてフォローを解除する
  end

  # 現在のユーザーがフォローしてたらtrueを返す
  def following?(other_user)
    following.include?(other_user)
  end
  
  
  
  
  #以下非公開
  private
  
  # メールアドレスを全て小文字にする
  def downcase_email
    self.email = email.downcase
  end
  
  
  # 有効かトークンとダイジェストを作成および代入する
  def create_activation_digest
    self.activation_token  = User.new_token                       #User.new_tokenメソッド（ランダムなトークンを返す）をアクセサ変数に代入
    self.activation_digest = User.digest(activation_token)         #既にデータベースのカラムとの関連付けができあがっているので、ユーザーが保存されるときに一緒に保存されます
  end
  
end

# --以下備考欄--
#　authenticateメソッド => 引数に渡された文字列（パスワード）をハッシュ化した値と、データベース内にあるpassword_digestカラムの値を比較
#※「トークン」とは、パスワードの平文と同じような秘密情報です。パスワードとトークンとの一般的な違いは、パスワードはユーザーが作成・管理する情報であるのに対し、トークンはコンピューターが作成・管理する情報である点です。
# selfというキーワードを使わないと、Rubyによってremember_tokenという名前のローカル変数が作成されてしまいます。 つまり、「remember_token」というrememberメソッド内で使えるローカル変数となってしまう
# cookiesメソッド　=>　２つのハッシュ値 、value（値）とexpires（有効期限）（expiresは省略可　20年で有効期限切れになる設定は、Railsのpermanentに専用メソッドが追加）
# feedのコード
# SELECT * FROM micropostsWHERE user_id IN (<list of ids>) OR user_id = <user id>　がSQL文