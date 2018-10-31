class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: 'Relationship',
            # active_relationshipというクラスはないが、class_nameオプションでクラス名を指定している。
            foreign_key: :follower_id,
            # デフォルトではuser_idとひもづくが、Relationshipクラスにはないので、明示している。
            dependent: :destroy
  has_many :passive_relationships, class_name: 'Relationship',
            foreign_key: :followed_id,
            dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  attr_accessor :remember_token, :activation_token, :reset_token
  # セッターとゲッターを用意して、一時的に保存する
  before_save   :downcase_email
  # DBに新しくデータが保存される時も、データが更新される時もどちらも反応する
  before_create :create_activation_digest
  # DBに新しくデータが保存される時だけ反応する

  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
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
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  # passwordに設定したvalidationはpassword_confirmationにも設定される
  # allow_nilオプションがtrueになっているが、has_secure_passwordではオブジェクト生成時に存在性をチェックしているのでからのパスワードが新規ユーザー登録時に有効になることはない

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

  #永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    #代入文であり、代入文の左辺の場合はselfを省略できない
    update_attribute(:remember_digest, User.digest(remember_token))
    #update_attributeを使うとvalidationをスキップできる
  end

  #渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  # メソッドとして作成すれば、何を行なっているかわかりやすくなる

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定用のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # ユーザーのステータスフィードを返す
  def feed
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)

    # following_idsはhas_manyを定義すると使えるようになる。集合に対してidだけを取得できる。
    # following_idsを実行した結果は配列だが、whereメソッドが判断して、文字列に変換してくれる。
    # 上のコードはwhereとfollowing_idsで２回呼び出しを行なっている。

    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
    # 上のコードはSQL内で式展開しているが、文字列の中に文字列を代入しているだけなので、ユーザーが改変する余地はない。
  end

  # ユーザーをフォローする
  def follow(other_user)
    self.following << other_user
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    self.active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # 現在のユーザーがフォローしてたらtrueを返す
  def following?(other_user)
    self.following.include?(other_user)
  end

  private

    # メールアドレスを全て小文字にする
    def downcase_email
      self.email = self.email.downcase
    end

    # 有効化トークンとダイジェストを作成及び代入する
    def create_activation_digest
      self.activation_token = User.new_token
      # activation_tokenは仮想的なものでDBには存在しない。attr_accessorで作った場所に一時的に保存される。
      self.activation_digest = User.digest(self.activation_token)
      # activation_digestはDBに存在する
    end



end
