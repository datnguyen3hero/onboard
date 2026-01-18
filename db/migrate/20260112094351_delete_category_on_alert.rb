class DeleteCategoryOnAlert < ActiveRecord::Migration[7.1]
  def change
    remove_column :alerts, :category
  end
end
