class Post < ApplicationRecord
  has_one_attached :image

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :liked_comments, through: :comment_reactions, source: :comment
  has_many :reports, as: :reportable, dependent: :destroy

  attr_accessor :remove_image

  validate :acceptable_image
  CATEGORIES = {
    1 => :technology,
    2 => :culture,
    3 => :health,
    4 => :sports,
    5 => :business
  }.freeze

  validates :title, presence: true, length: { minimum: 5 }
  validates :content, presence: true
  validates :category, presence: true, inclusion: {
    in: CATEGORIES.keys.map(&:to_s),
    message: :invalid_category
  }

  after_save :purge_image_if_requested

  def category_name
    I18n.t("posts.categories.#{CATEGORIES[category.to_i]}")
  end

  private

  def acceptable_image
    return unless image.attached?

    acceptable_types = [ "image/jpeg", "image/png", "image/webp" ]
    unless acceptable_types.include?(image.blob.content_type)
      errors.add(:image, :invalid_format)
    end

    if image.blob.byte_size > 5.megabytes
      errors.add(:image, :too_large)
    end
  end

  def purge_image_if_requested
    image.purge_later if ActiveModel::Type::Boolean.new.cast(remove_image)
  end
end
