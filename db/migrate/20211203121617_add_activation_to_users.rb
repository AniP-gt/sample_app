class AddActivationToUsers < ActiveRecord::Migration[6.0]
  # アカウント有効化用の属性とインデックスを追加するマイグレーション
  def change
    add_column :users, :activation_digest, :string
    add_column :users, :activated, :boolean, default: false
    add_column :users, :activated_at, :datetime
  end
end
