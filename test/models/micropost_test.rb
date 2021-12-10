require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  # fixtureのサンプルユーザーと紐付けた新しいマイクロポストを作成
  def setup
    @user = users(:michael)
    # 慣習的に正しくマイクロポストを作成する                                                                                                   # このコードは慣習的に正しくない
     @micropost = @user.microposts.build(content: "Lorem ipsum")                #	userに紐付いた新しいMicropostオブジェクトを返す              # @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
  end

  # 現実に即しているかどうかをテスト（reality check）
  test "should be valid" do
    assert @micropost.valid?
  end

  # user_idが存在しているかどうか（nilではないか）をテスト
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end
  
  # コンテンツが存在するか
  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  # 140文字以内であるか
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end  
  
end