class SessionsController < ApplicationController
  def new

  end

  def create
    user = User.find_by(email: params[:session][:email])
    # @user.authenticate(params[:session][:password])
    #=> Userオブジェクト　または false

    if user && user.authenticate(params[:session][:password])
    
    else
      flash[:danger] = "Invalid email/password combination"
      render 'new'
    end
  end
end
