class User < ApplicationRecord
  has_secure_password

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :comment_reactions, dependent: :destroy
  has_many :liked_comments, through: :comment_reactions, source: :comment
  has_many :reports, dependent: :destroy

  ROLES = %w[user admin moderator].freeze
  PASSWORD_FORMAT = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}\z/.freeze

  before_validation :set_default_role, on: :create

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :password, format: {
    with: PASSWORD_FORMAT,
    message: "debe incluir al menos una letra mayúscula, una letra minúscula, un número y un carácter especial (por ejemplo: !, @, #, $, %, &, *)."
  }, allow_nil: true
  validates :username, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLES }

  def admin?
    role == "admin"
  end

  private

  def set_default_role
    self.role ||= "user"
  end
end
