class ChangeDatatypeInUsers < ActiveRecord::Migration[8.1]
  def up
    change_column :users,
                  :reset_otp_sent_at,
                  :datetime,
                  using: "reset_otp_sent_at::timestamp"
  end

  def down
    change_column :users,
                  :reset_otp_sent_at,
                  :string,
                  using: "reset_otp_sent_at::text"
  end
end
