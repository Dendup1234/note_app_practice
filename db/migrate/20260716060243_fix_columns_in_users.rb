class FixColumnsInUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :pin, :string
    remove_column :users, :pin_sent_at, :string

    add_column :users, :register_otp, :text
    add_column :users, :register_otp_sent_at, :text
    add_column :users, :reset_otp, :text
    add_column :users, :reset_otp_sent_at, :text
  end
end
