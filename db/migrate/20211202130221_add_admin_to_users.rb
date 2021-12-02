class AddAdminToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :admin, :boolean, default: false #default: false引数を与えない場合、 adminの値はデフォルトでnilになります => デフォルトでは管理者になれないということを示す
  end
end
