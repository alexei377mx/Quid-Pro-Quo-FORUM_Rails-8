class User < ApplicationRecord
  has_secure_password

  has_many :posts, dependent: :destroy

  ROLES = %w[user admin moderator].freeze

  before_validation :set_default_role, on: :create

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :username, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLES }

  private

  def set_default_role
    self.role ||= "user"
  end
end
