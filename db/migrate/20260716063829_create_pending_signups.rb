class CreatePendingSignups < ActiveRecord::Migration[8.1]
  def change
    create_table :pending_signups do |t|
      t.string :username
      t.string :email
      t.string :password_digest
      t.string :otp
      t.datetime :otp_sent_at
      t.datetime :expires_at

      t.timestamps
    end
  end
end
