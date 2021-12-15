class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"            #フォローを返す
  belongs_to :followed, class_name: "User"            #フォローしているユーザーを返す
  validates :follower_id, presence: true              #検証用の設定
  validates :followed_id, presence: true                
end
