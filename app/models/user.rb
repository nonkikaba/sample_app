class User < ApplicationRecord
  attr_accessor :remember

  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  #VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: {case_sensitive: false}
                    #case_sensitiveオプションで大文字と小文字を区別するか選択。デフォルトはtrue。falseの場合区別しない
  has_secure_password
=begin
has_secure_passwordの説明
    セキュアにハッシュ化したパスワードを、データベース内のpassword_digestという属性に保存できるようになる。
    2つのペアの仮想的な属性 (passwordとpassword_confirmation) が使えるようになる。また、存在性と値が一致するかどうかのバリデーションも追加される。
    authenticateメソッドが使えるようになる (引数の文字列がパスワードと一致するとUserオブジェクトを、間違っているとfalseを返すメソッド) 
=end
  validates :password, presence: true, length: { minimum: 6 }
  # passwordに設定したvalidationはpassword_confirmationにも設定される

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    #クラスメソッド
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
    #テスト環境では時間をかけて複雑なハッシュ化をする必要がないので、costオプションで簡単なものにしている
  end

  #ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end
end
