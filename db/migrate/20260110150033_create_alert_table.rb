class CreateAlertTable < ActiveRecord::Migration[7.1]
  def change
    if ActiveRecord::Base.connection.table_exists?(:"alerts")
      drop_table :"alerts"
    end
    create_table :"alerts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string :type, null: false, index: { name: "index_alerts_on_type" }
      t.string :title, null: false, index: { name: "index_alerts_on_title", unique: true }
      t.string :body
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
