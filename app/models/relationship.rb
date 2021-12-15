class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"            #フォローを返す
  belongs_to :followed, class_name: "User"            #フォローしているユーザーを返す
end
