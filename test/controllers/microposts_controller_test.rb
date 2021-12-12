require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  
  # テストユーザーのセットアップ
  def setup
    @micropost = microposts(:orange)
  end

# 間違ったユーザーによるマイクロポスト削除に対してテスト
# ログインしていないときにcreateをリダイレクトする必要があります
  test "should redirect create when not logged in" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
    end
    assert_redirected_to login_url
  end

# ログインしていないときに破棄をリダイレクトする必要があります
  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_url
  end

# 間違ったマイクロポストの破棄をリダイレクトする必要があります
  test "should redirect destroy for wrong micropost" do
    log_in_as(users(:michael))
    micropost = microposts(:ants)
    assert_no_difference 'Micropost.count' do
      delete micropost_path(micropost)
    end
    assert_redirected_to root_url
  end
end
