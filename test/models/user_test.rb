require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  #app/models/users.rbのテスト
  #setup内におけるインスタンス変数の定義、どこでも使える特殊な変数
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")  
  end
  
  # @userの有効性テスト
  test "should be valid" do
    assert @user.valid?
  end
  
  #nameの存在性テスト
  test "name should be present" do
    @user.name = " "
    assert_not @user.valid?
  end  
  
  #emailの存在性テスト
    test "email should be present" do
    @user.email = " "
    assert_not @user.valid?
  end  
  
  #nameの長さテスト・・・50文字までか
  test "name should not be too long"do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  
  #emailの長さテスト・・・255文字までか
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  
  #有効なメールフォーマットのテスト
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} shouldbe valid"  #エラーメッセージ
    end
  end
  
  #メールフォーマットの検証に対するテスト
  test "email validation should reject invalid addresses" do
    invalid_address = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_address.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
  
  #大文字、小文字を区別しない、一意性のテスト
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email =@user.email.upcase  #大文字にする
    @user.save
    assert_not duplicate_user.valid?
  end
  
  #パスワードが空でないテスト
  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = "" * 6
    assert_not @user.valid?
  end
  
  #パスワードの長さが6文字以上であることのテスト
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  
  # ダイジェストが存在しない場合のauthenticated?のテスト　ログアウトバグ２つ目のテスト
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
  
  # 関連するマイクロポストは破棄する必要があります  dependent: :destroyのテスト
  test "associated microposts should be destroyed" do
    @user.save                                                  #（idを紐づけるための）ユーザーを作成
    @user.microposts.create!(content: "Lorem ipsum")            #そのユーザーに紐付いたマイクロポストを作成
    assert_difference 'Micropost.count', -1 do                  #その後、ユーザーを削除してみて、マイクロポストの数が1つ減っているかどうかを確認
      @user.destroy   
    end
  end  
  
  # ユーザーをフォローおよびフォロー解除する必要があります
  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer  = users(:archer)
    assert_not michael.following?(archer)                       #following?メソッドであるユーザーをまだフォローしていないことを確認
    michael.follow(archer)                                      #followメソッドを使ってそのユーザーをフォロー
    assert michael.following?(archer)                           #following?メソッドを使ってフォロー中になったことを確認
    assert archer.followers.include?(michael)                   #followersに対するテスト 
    michael.unfollow(archer)                                    #unfollowメソッドでフォロー解除できたことを確認
    assert_not michael.following?(archer)                       #following?メソッドであるユーザーを再度フォローしていないことを確認
  end  
  
  # フィードには適切な投稿が必要です
  test "feed should have the right posts" do
    michael = users(:michael)
    archer  = users(:archer)
    lana    = users(:lana)
    # フォローしているユーザーの投稿を確認
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end
    # 自分自身の投稿を確認
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end
    # フォローしていないユーザーの投稿を確認
    archer.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end
  end
  
end
