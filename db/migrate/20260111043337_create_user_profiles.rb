class CreateUserProfiles < ActiveRecord::Migration[7.1]
  def change
    if ActiveRecord::Base.connection.table_exists?(:user_profiles)
      drop_table :user_profiles
    end
    create_table :user_profiles, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true, index: { name: "index_user_profiles_on_user_id", unique: true }
      t.string :full_name, null: false
      t.string :address
      t.date :date_of_birth
      t.timestamps
    end
  end
end
