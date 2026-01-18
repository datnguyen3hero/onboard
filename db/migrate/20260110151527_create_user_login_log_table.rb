class CreateUserLoginLogTable < ActiveRecord::Migration[7.1]
  def change
    if ActiveRecord::Base.connection.table_exists?(:user_login_log)
      drop_table :user_login_log
    end
    create_table :user_login_log, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true

      t.boolean :success, default: true
      t.timestamps
    end
  end
end
