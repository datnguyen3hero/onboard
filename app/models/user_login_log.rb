class UserLoginLog < ApplicationRecord
  self.table_name = :user_login_log
  # belong_to is used in child table. (this means the foreign key is in this table)
  belongs_to :user
end
