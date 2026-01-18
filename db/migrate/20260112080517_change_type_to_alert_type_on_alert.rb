class ChangeTypeToAlertTypeOnAlert < ActiveRecord::Migration[7.1]
  def change
    rename_column :alerts, :type, :alert_type
  end
end
