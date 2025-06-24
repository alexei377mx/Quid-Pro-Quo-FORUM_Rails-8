class User < ApplicationRecord
  has_secure_password

  has_one_attached :avatar

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :comment_reactions, dependent: :destroy
  has_many :liked_comments, through: :comment_reactions, source: :comment
  has_many :reports, dependent: :destroy

  ROLES = %w[user admin moderator].freeze
  PASSWORD_FORMAT = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}\z/.freeze
  USERNAME_FORMAT = /\A[a-zA-Z0-9_-]+\z/.freeze

  before_validation :set_default_role, on: :create
  validate :avatar_size_validation

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :password, format: {
    with: PASSWORD_FORMAT,
    message: :invalid_password_format
  }, allow_nil: true
  validates :username,
    presence: true,
    uniqueness: true,
    format: {
      with: USERNAME_FORMAT,
      message: :invalid_username_format
    }
  validates :role, presence: true, inclusion: { in: ROLES, message: :invalid_role }

  def admin?
    role == "admin"
  end

  def check_for_ban!(controller = nil)
    total_deleted = posts.where(deleted_by_admin: true).count +
                    comments.where(deleted_by_admin: true).count

    if total_deleted >= 5 && !banned?
      update(banned: true)
      Rails.logger.info("Usuario #{id} ha sido baneado automáticamente por contenido eliminado.")
      controller&.flash[:warning] = I18n.t("users.ban_message", username: username)
    end
  end

  private

  def set_default_role
    self.role ||= "user"
  end

  def avatar_size_validation
    return unless avatar.attached?

    if avatar.blob.byte_size > 1.megabyte
      errors.add(:avatar, :avatar_too_big)
    end

    acceptable_types = [ "image/jpeg", "image/png", "image/webp" ]
    unless acceptable_types.include?(avatar.content_type)
      errors.add(:avatar, :avatar_invalid_format)
    end
  end
end
