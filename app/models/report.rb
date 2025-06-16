class Report < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true

  REASONS = [
    "Contenido ofensivo",
    "Spam o publicidad no solicitada",
    "Información falsa o engañosa",
    "Acoso o abuso",
    "Lenguaje inapropiado",
    "Otro"
  ].freeze

  validates :reason, presence: true, inclusion: { in: REASONS, message: "no es una razón válida" }

  scope :without_deleted_content, lambda {
    joins(<<~SQL)
      LEFT JOIN posts ON posts.id = reports.reportable_id AND reports.reportable_type = 'Post'
      LEFT JOIN comments ON comments.id = reports.reportable_id AND reports.reportable_type = 'Comment'
      LEFT JOIN posts AS comment_posts ON comment_posts.id = comments.post_id
    SQL
    .where(<<~SQL, false, false)
      (reports.reportable_type != 'Post' OR posts.deleted_by_admin = ?) AND
      (reports.reportable_type != 'Comment' OR comment_posts.deleted_by_admin = ?)
    SQL
  }

  scope :by_type, ->(type) { where(reportable_type: type) if type.present? }
  scope :by_reviewed, ->(reviewed) {
    if reviewed.in?([ true, false ])
      where(reviewed: reviewed)
    else
      all
    end
  }
  scope :by_date_range, ->(from, to) {
    if from.present? && to.present?
      where(created_at: from.beginning_of_day..to.end_of_day)
    else
      all
    end
  }
end
