class User < ApplicationRecord
  before_save { self.email = email.downcase}                  #emailの小文字化
  validates :name, presence: true, length: { maximum: 50}     #name属性の存在性を検証、最大50文字まで
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i    #完全な正規表現
  validates :email, presence: true, length: { maximum: 255},  #emailの存在性を検証、最大255文字まで
                    format: {with: VALID_EMAIL_REGEX},        #formatオプションを用いて、引数に正規表現を取る
                    uniqueness: {case_sensitive: false}       #メールアドレスの大文字小文字を無視した一意性の検証
  has_secure_password                                         #セキュアなパスワードを持っている
  validates :password, presence: true, length: {minimum: 6}   #password属性の存在性を検証、最小6文字から
end
