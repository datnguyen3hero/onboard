class AddSeverityAndCategoryAndStatusToAlert < ActiveRecord::Migration[7.1]
  def change
    add_column :alerts, :severity, :string, default: "medium", null: false
    add_column :alerts, :status, :integer, default: 0, null: false
    add_column :alerts, :category, :string , default: "general", null: false

    add_index :alerts, [:severity, :created_at], name: "index_alerts_on_severity_and_created_at"
    add_index :alerts, [:category], name: "index_alerts_on_category"
  end
end
