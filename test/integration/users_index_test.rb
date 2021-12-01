require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  
  # テストユーザー
  def setup
    @user = users(:michael)
  end
  
  # ページネーションを含めたUsersIndexのテスト
  test "index includeing pagination" do 
    log_in_as(@user)                                                    #ログイン
    get users_path                                  
    assert_template 'users/index'                                       #indexに遷移
    assert_select 'div.pagination'                                      #paginationクラスを持ったdivタグをチェック
    User.paginate(page: 1).each do |user|                               #最初のページにユーザーがいることを確認
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end
  
end
