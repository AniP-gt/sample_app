# 作成したモデルオブジェクトはデータベースにアクセスできるようになり、データベースのカラムをあたかもRubyの属性のように扱える
# モデルオブジェクトの操作や、送られてくるHTTP requestのフィルタリング、ビューをHTMLとして出力などの多彩な機能を実行できる
# Active Recordには、オブジェクトを検索
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
