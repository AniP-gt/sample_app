# ユーザーが明示的にログアウトを実行しない限り、ログイン状態を維持することができる
class AddRememberDigestToUsers < ActiveRecord::Migration[6.0]
  # DBにrememberカラムを追記
  def change
    add_column :users, :remember_digest, :string
  end
end
