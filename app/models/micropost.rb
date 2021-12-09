# 自動生成されたMicropostモデル
class Micropost < ApplicationRecord
  belongs_to :user                      #ユーザーと１対１の関係であることを表す
end


#--備考欄--
#Userモデルとの最大の違いはreferences型を利用している点です。これを利用すると、自動的にインデックスと外部キー参照付きのuser_idカラムが追加され3 、UserとMicropostを関連付けする下準備をしてくれます