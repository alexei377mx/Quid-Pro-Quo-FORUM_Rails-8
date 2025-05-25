class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy
  has_many :comment_reactions, dependent: :destroy
  has_many :liked_by_users, through: :comment_reactions, source: :user


  validates :content, presence: true
  validates :content, length: { minimum: 2 }

  def edited?
    updated_at > created_at
  end

  def likes_count
    comment_reactions.count
  end
end
