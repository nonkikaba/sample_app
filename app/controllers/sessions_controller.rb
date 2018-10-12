class SessionsController < ApplicationController
  def new
    
  end

  def create
    user = User.find_by(email: params[:session][:email])
    # @user.authenticate(params[:session][:password])
    # => Userオブジェクト　または false

    if user && user.authenticate(params[:session][:password])
      if user.activated?
        # メール認証が済んでいなければログインさせない
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or user
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      # flash[:danger] = "Invalid email/password combination"
      # flashの生存期間は次のリクエストが来るまで。renderは新しいリクエストを発行するわけではないのでこのままだとflashメッセージが生き残る。flash.now[]とすると解決
      flash.now[:danger] = "Invalid email/password combination"
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
