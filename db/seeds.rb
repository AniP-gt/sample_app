# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


# メインのサンプルユーザーを1人作成する
User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true,                             #特権を持つ管理ユーザー
             activated: true,                         #アカウント有効化である　=>true
             activated_at: Time.zone.now              #サーバーのタイムゾーンに応じたタイムスタンプを返します
             )

# 追加のユーザーをまとめて生成する
99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now
               )
end

# ユーザーの一部を対象にマイクロポストを生成する
users = User.order(:created_at).take(6)                                 #orderメソッドを経由することで、作成されたユーザーの最初の6人を明示的に呼び出す
50.times do                                                             #50個のマイクロポスト
  content = Faker::Lorem.sentence(word_count: 5)                        #各投稿内容  Faker gemにLorem.sentenceという便利なメソッドを使用
  users.each { |user| user.microposts.create!(content: content) }       #ユーザー毎に50個分のマイクロポストをまとめて作成してしまうと、ステータスフィードに表示される投稿がすべて同じユーザーになってしまい、視覚的な見栄えが悪くなる
end


# 以下のリレーションシップを作成する
users = User.all
user  = users.first
following = users[2..50]                                                #最初のユーザーにユーザー3からユーザー51までをフォローさせ
followers = users[3..40]                                                #逆にユーザー4からユーザー41に最初のユーザーをフォローさせます
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }

# create!は基本的にcreateメソッドと同じものですが、ユーザーが無効な場合にfalseを返すのではなく例外を発生させる