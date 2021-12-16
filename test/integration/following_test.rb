require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  
  # セットアップ
  def setup
    @user = users(:michael)
    log_in_as(@user)
  end

  
  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?                               #結果がtrueであれば、assert_select内のブロックが実行されなくなるため、その場合においてテストが適切なセキュリティモデルを確認できなくなることを防いでいます
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end
end
