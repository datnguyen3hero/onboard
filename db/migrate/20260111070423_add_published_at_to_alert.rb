class AddPublishedAtToAlert < ActiveRecord::Migration[7.1]
  def change
    add_column :alerts, :published_at, :timestamp
  end
end
