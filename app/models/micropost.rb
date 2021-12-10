# 自動生成されたMicropostモデル
class Micropost < ApplicationRecord
  belongs_to :user                                                          #ユーザーと１対１の関係であることを表す
  default_scope -> { order(created_at: :desc) }                             #あるスコープをモデルのすべてのクエリに適用したい場合、モデル自身の内部でdefault_scopeメソッド desc（降順） => 新しい投稿順に並び替える
  validates :user_id, presence: true                                        #マイクロポストのuser_idに対する検証
  validates :content, presence: true, length: { maximum: 140 }              #content属性の検証　140文字まで　
end


#--備考欄--
#Userモデルとの最大の違いはreferences型を利用している点です。これを利用すると、自動的にインデックスと外部キー参照付きのuser_idカラムが追加され3 、UserとMicropostを関連付けする下準備をしてくれます