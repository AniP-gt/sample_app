require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper                                         #app/helpers/application_helper.rb

# テストユーザーの設定
  def setup
    @user = users(:michael)
  end

# 
  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'                                    #ページを表示
    assert_select 'title', full_title(@user.name)                   #ApplicationHeloer要素のテスト
    assert_select 'h1', text: @user.name                            #h1タグにユーザーの名前が表示されている
    assert_select 'h1>img.gravatar'                                 #h1タグ（トップレベルの見出し）の内側にある、gravatarクラス付きのimgタグがあるかどうか
    assert_match @user.microposts.count.to_s, response.body         #そのページの完全なHTMLが含まれています（HTMLのbodyタグだけではありません）
    assert_select 'div.pagination'                                  #divタグにページネーションが表示されている
    @user.microposts.paginate(page: 1).each do |micropost|          #HTML内にページネーションが表示されている
      assert_match micropost.content, response.body
    end
  end
end
