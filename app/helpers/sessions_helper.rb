module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  #ユーザーのセッションを永続的に保存する
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 渡されたユーザーがログイン済みユーザーであればtrueを返す
  def current_user?(user)
    user == current_user
  end

  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    if user_id = session[:user_id]
      #session情報が保存されている場合
      @current_user ||= User.find_by(id: user_id)
      #findで検索するとsession[:user_id]がnilの場合に例外を発生させる。find_byで検索すればsession[:user_id]がnilの時はnilを返す
    elsif user_id = cookies.signed[:user_id]
      #session情報はないが、cookie情報は保存されている場合
      #ここでのuser_idは署名付きuser_idなので復号化する必要がある。複合化するにはsignedとつければ良い。逆に暗号化する場合もsignedをつければ暗号化できる
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end 
    end
    #ifにもelsifにも引っかからなかった場合、nilを返す
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  #永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  #現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # 記憶したURL (もしくはデフォルト値) にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
