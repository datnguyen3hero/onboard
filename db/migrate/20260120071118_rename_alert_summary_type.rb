class RenameAlertSummaryType < ActiveRecord::Migration[7.1]
  def change
    rename_column :alert_summary, :type, :alert_summary_type
  end
end
