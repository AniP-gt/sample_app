require 'test_helper'

class RelationshipsControllerTest < ActionDispatch::IntegrationTest
  
  # createにはログインユーザーが必要です
  test "create should require logged-in user" do
    assert_no_difference 'Relationship.count' do                        #コントローラのアクションにアクセスするとき、ログイン済みのユーザーであるかどうかをチェック
      post relationships_path
    end
    assert_redirected_to login_url                                      #もしログインしていなければログインページにリダイレクトされるので、Relationshipのカウントが変わっていないことを確認
  end

# destroyにはログインユーザーが必要です
  test "destroy should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      delete relationship_path(relationships(:one))
    end
    assert_redirected_to login_url
  end
end
