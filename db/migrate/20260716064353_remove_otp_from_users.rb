class RemoveOtpFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :register_otp, :string
    remove_column :users, :register_otp_sent_at, :string
    remove_column :users, :verified, :boolean
  end
end
