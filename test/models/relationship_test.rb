require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  
  # セットアップ
  def setup
    @relationship = Relationship.new(follower_id: users(:michael).id,
                                     followed_id: users(:archer).id)
  end

  # 有効かどうか
  test "should be valid" do
    assert @relationship.valid?
  end
  
  # follower_idが必要です
  test "should require a follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  # follow_idが必要です
  test "should require a followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
end
