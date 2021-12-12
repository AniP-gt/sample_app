# 自動生成されたMicropostモデル
class Micropost < ApplicationRecord
  belongs_to :user                                                          #ユーザーと１対１の関係であることを表す
  has_one_attached :image                                                   #Active Storageの中のhas_one_attachedメソッド　 指定のモデルと、アップロードされたファイルを関連付ける
  default_scope -> { order(created_at: :desc) }                             #あるスコープをモデルのすべてのクエリに適用したい場合、モデル自身の内部でdefault_scopeメソッド desc（降順） => 新しい投稿順に並び替える
  validates :user_id, presence: true                                        #マイクロポストのuser_idに対する検証
  validates :content, presence: true, length: { maximum: 140 }              #content属性の検証　140文字まで　
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],       #文字列の配列を簡単に作れる%wメソッド
                                      message: "must be a valid image format" },    #
                      size:         { less_than: 5.megabytes,                       #比較文　
                                      message: "should be less than 5MB" }  
end


#--備考欄--
#Userモデルとの最大の違いはreferences型を利用している点です。これを利用すると、自動的にインデックスと外部キー参照付きのuser_idカラムが追加され3 、UserとMicropostを関連付けする下準備をしてくれます