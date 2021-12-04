class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@example.com'         #fromアドレスのデフォルト値を更新したアプリケーションメイラー
  layout 'mailer'
end
