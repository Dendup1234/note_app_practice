class AddEmailVerificationToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :pin, :integer
    add_column :users, :pin_sent_at, :datetime
    add_column :users, :verified, :boolean, default: false
  end
end
