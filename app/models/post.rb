class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :liked_comments, through: :comment_reactions, source: :comment

  CATEGORIES = [ "Tecnología", "Cultura", "Salud", "Deportes", "Negocios" ].freeze

  validates :title, presence: true
  validates :content, presence: true
  validates :title, length: { minimum: 5 }
  validates :category, presence: true, inclusion: { in: CATEGORIES, message: "%{value} no es una categoría válida" }
end
