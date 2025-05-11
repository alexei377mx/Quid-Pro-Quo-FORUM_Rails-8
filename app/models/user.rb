class User < ApplicationRecord
  has_secure_password

  ROLES = %w[user admin moderator].freeze

  

  validates :name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLES }

  private

  def set_default_role
    self.role ||= 'user'
  end
end
