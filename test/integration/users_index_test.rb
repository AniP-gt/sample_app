require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  
  # テストユーザー
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end
  
  # ページ付けと削除リンクを含む管理者としてのインデックス
  test "index as admin includeing pagination and delete links" do 
    log_in_as(@admin)                                                    #ログイン
    get users_path                                  
    assert_template 'users/index'                                       #indexに遷移
    assert_select 'div.pagination'                                      #paginationクラスを持ったdivタグをチェック
    first_page_of_users = User.paginate(page: 1)                        #変数first_page_of_usersにページネートの１枚目のユーザーを代入
    first_page_of_users.each do |user|                                  #変数userに代入
      assert_select 'a[href=?]', user_path(user), text: user.name       #
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
      assert_difference 'User.count', -1 do                           #DELETEリクエストを適切なURLに向けて発行し、User.countを使ってユーザー数が1 減ったかどうかを確認
        delete user_path(@non_admin)
      end
    end
  
  # non_adminとしてのインデックス
  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
  
end
