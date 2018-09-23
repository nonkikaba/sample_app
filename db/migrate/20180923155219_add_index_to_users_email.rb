class AddIndexToUsersEmail < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :email, unique: true
    #ほぼ同時に同一のアドレスが登録された場合、DB上に同じメールアドレスをもつユーザーレコードが作成される状況が起こりうる
    #この問題はデータベースでも一意性を強制することで解決できる。さらに検索を高速にするためインデックスをつける
  end
end
