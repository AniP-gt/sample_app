class AddPasswordDigestToUsers < ActiveRecord::Migration[6.0]
  # DBにpassword_digestカラムを追加　=>　Gemfileにてbcryptの設定をする
  def change
    add_column :users, :password_digest, :string
  end
end
