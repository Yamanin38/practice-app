class User < ApplicationRecord
  has_secure_password
  has_many :images, dependent: :destroy
  has_many :articles, dependent: :destroy
  has_secure_token :session_token # セッション管理のためのトークンを生成するメソッドを追加

  enum :role, { member: 0, admin: 1 }

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record? || password.present? }
  validates :password_confirmation, presence: true, if: -> { new_record? || password.present? }
end
