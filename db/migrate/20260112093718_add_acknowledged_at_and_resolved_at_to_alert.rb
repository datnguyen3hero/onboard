class AddAcknowledgedAtAndResolvedAtToAlert < ActiveRecord::Migration[7.1]
  def change
    add_column :alerts, :acknowledged_at, :datetime
    add_column :alerts, :resolved_at, :datetime
  end
end
