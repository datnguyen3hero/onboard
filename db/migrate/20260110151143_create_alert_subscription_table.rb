class CreateAlertSubscriptionTable < ActiveRecord::Migration[7.1]
  def change
    if ActiveRecord::Base.connection.table_exists?(:alert_subscriptions)
      drop_table :alert_subscriptions
    end
    create_table :alert_subscriptions, id: :uuid, default: -> { 'uuid_generate_v4()' }, force: :cascade do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :alert, type: :uuid, null: false, foreign_key: true

      t.boolean :email_enabled, default: true
      t.boolean :push_enabled, default: false

      t.timestamps
    end

    # when create foreign key, rails will auto create index, so here we create a unique index for combination of user_id and alert_id
    add_index :alert_subscriptions, [:user_id, :alert_id], name: 'index_alert_subscriptions_on_user_id_and_alert_id',
                                                           unique: true
  end
end
