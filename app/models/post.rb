class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :comment_reactions, dependent: :destroy
  has_many :liked_comments, through: :comment_reactions, source: :comment


  validates :title, presence: true
  validates :content, presence: true
  validates :title, length: { minimum: 5 }
end
