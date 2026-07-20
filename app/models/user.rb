class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true
  validates :email, uniqueness: { case_sensitive: false }, presence: true
  has_many :notes, dependent: :destroy
end
