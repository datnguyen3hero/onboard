class AddTokenColumnToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :token, :string
    add_index :users, :token, name: "index_users_on_token"
  end
end
