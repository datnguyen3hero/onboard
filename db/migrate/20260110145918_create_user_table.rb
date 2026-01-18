class CreateUserTable < ActiveRecord::Migration[7.1]
  def change
    if ActiveRecord::Base.connection.table_exists?(:users)
      drop_table :users
    end
    create_table :users, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string :name
      t.string :email, null: false, index: { name: "index_users_on_email", unique: true }
      t.string :timezone, default: "UTC"
      t.timestamps
    end
  end
end
