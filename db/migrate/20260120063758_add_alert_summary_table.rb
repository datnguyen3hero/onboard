class AddAlertSummaryTable < ActiveRecord::Migration[7.1]
  def change
    if ActiveRecord::Base.connection.table_exists?(:alert_summary)
      drop_table :alert_summary
    end
    create_table :alert_summary, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string :type, null: false, index: { name: "index_alert_summary_on_type" }
      t.string :title, null: false, index: { name: "index_alert_summary_on_title" }
      t.string :body
      t.boolean :active, default: true
      t.string :summary

      t.timestamps
    end
  end
end
