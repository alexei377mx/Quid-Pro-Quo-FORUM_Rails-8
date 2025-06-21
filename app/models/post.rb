class Post < ApplicationRecord
  has_one_attached :image

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :liked_comments, through: :comment_reactions, source: :comment
  has_many :reports, as: :reportable, dependent: :destroy

  attr_accessor :remove_image

  validate :acceptable_image

  CATEGORIES = [ "Tecnología", "Cultura", "Salud", "Deportes", "Negocios" ].freeze

  validates :title, presence: true, length: { minimum: 5 }
  validates :content, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES, message: "%{value} no es una categoría válida" }

  after_save :purge_image_if_requested

  private

  def acceptable_image
    return unless image.attached?

    acceptable_types = [ "image/jpeg", "image/png", "image/webp" ]
    unless acceptable_types.include?(image.blob.content_type)
      errors.add(:image, "debe ser JPEG, PNG o WebP")
    end

    if image.blob.byte_size > 5.megabytes
      errors.add(:image, "es demasiado grande (máximo 5 MB)")
    end
  end


  def purge_image_if_requested
    image.purge_later if ActiveModel::Type::Boolean.new.cast(remove_image)
  end
end
