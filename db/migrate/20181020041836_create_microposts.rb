class CreateMicroposts < ActiveRecord::Migration[5.1]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, foreign_key: true
      # foreign_keyオプションで明示した方が、DB側で最適化してくれる

      t.timestamps
    end
    add_index :microposts, [:user_id, :created_at]
  end
end
