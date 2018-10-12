class UserMailer < ApplicationMailer

  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
    # mailメソッドを実行すると以下のテンプレートが呼び出される
    # =>  app/views/user_mailer/account_activation.text.erb
    # =>  app/views/user_mailer/account_activation.html.erb
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end
