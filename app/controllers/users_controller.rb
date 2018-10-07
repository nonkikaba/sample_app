class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  # patchリクエストを直接飛ばせば、updateアクションを直接実行できるためbeforeフィルターにupdateアクションを追加している
  before_action :correct_user,   only: [:edit, :update]

  def show
    @user = User.find(params[:id])
    # debugger
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save #=> validation
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    # findは失敗した時に例外を返すので、nilチェックはできている
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    # ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    # logged_in_userメソッドでログイン状態を確認しているので、correct_userメソッドでは確認する必要がない.
    # current_userのnilチェックは必要ない
end
