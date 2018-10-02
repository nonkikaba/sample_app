class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  #helpersはデフォルトでテンプレートにincludeするが、コントローラーでは明示しなければならない
  def hello
    render html: "hello, world"
  end
end
